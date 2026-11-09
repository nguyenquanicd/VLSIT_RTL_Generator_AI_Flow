# cocotbext-qspi

QSPI flash verification for [cocotb](https://www.cocotb.org/): a bus driver,
a device-level API over the JEDEC command set, and a NOR flash model to test
against.

Requires **cocotb 2.0+**. Tests run on Icarus Verilog.

```
pip install cocotbext-qspi
```

## Why another SPI extension

[`cocotbext-spi`](https://github.com/schang412/cocotbext-spi) covers
single-lane SPI. This one covers flash specifically: dual and quad I/O
reads, the write-enable latch, status polling, page program and sector
erase — and it targets cocotb 2.x.

## Pointing a testbench at the models

The Verilog ships inside the package, so there is nothing to vendor. Ask the
package where it is:

```make
VERILOG_DIR := $(shell python3 -c \
    "import cocotbext.qspi as q; print(q.verilog_dir())")

VERILOG_SOURCES  = $(VERILOG_DIR)/qspi_flash.v
VERILOG_SOURCES += $(VERILOG_DIR)/qspi_flash_test.v
```

Or from Python, `cocotbext.qspi.verilog_dir()` returns a `pathlib.Path`.

## Usage

```python
import cocotb
from cocotb.clock import Clock
from cocotbext.qspi import QspiFlash, CMD_QIOR4

@cocotb.test()
async def test_flash(dut):
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())

    flash = QspiFlash(dut)
    await flash.initialize()

    assert await flash.read_id() == [0xEF, 0x40, 0x18]

    # program() sets WEL, then polls the status register until WIP clears.
    await flash.program(0x1000, [0xDE, 0xAD, 0xBE, 0xEF])

    assert await flash.read(0x1000, 4) == [0xDE, 0xAD, 0xBE, 0xEF]
    assert await flash.read(0x1000, 4, opcode=CMD_QIOR4) == [0xDE, 0xAD, 0xBE, 0xEF]

    await flash.erase_sector(0x1000)
    assert await flash.read(0x1000, 4) == [0xFF] * 4
```

## The protocol, and two things that catch people out

SPI mode 0: the master launches data while the clock is low, the device
samples it on the rising edge, and vice versa.

**The opcode is always single-lane.** Only the address, mode byte and data
widen. A quad I/O read is *not* "everything on four lanes" — it is one
single-lane command byte, then four-lane address and data. Getting this
wrong is the most common reason a driver talks to nothing.

**Programming only clears bits.** NOR flash needs an erase to set a bit back
to 1. Programming `0x0F` over `0xF0` gives `0x00`, not `0x0F`.

### What it looks like on the wire

All three diagrams below are generated from a real simulation — `capture.py`
runs the transactions, Icarus dumps a VCD, and `render.py` draws it. Nothing
is drawn by hand, so they cannot drift away from what the model does.

A quad I/O read. The opcode goes out one bit per clock on a single lane; only
then does the bus widen to four lanes for the address and data. Note the
eight dummy cycles, where neither side drives while the bus turns around:

![Fast read quad I/O](https://raw.githubusercontent.com/JitheshVijay/cocotbext-qspi/v0.2.0/docs/waveforms/quad-read.png)

The same byte read three ways. This is the whole point of the wide modes —
40 clocks single-lane, 36 dual, 26 quad, for one byte at the same address:

![One byte, three widths](https://raw.githubusercontent.com/JitheshVijay/cocotbext-qspi/v0.2.0/docs/waveforms/width-comparison.png)

A status read while a program is in flight. The device answers `0x01` — WIP
set — which is what `wait_ready()` polls for:

![Read status](https://raw.githubusercontent.com/JitheshVijay/cocotbext-qspi/v0.2.0/docs/waveforms/read-status.png)

To regenerate them:

```
make -C docs/waveforms        # run the sim, dump capture.vcd
make -C docs/waveforms svg    # capture.vcd -> *.svg
```

### Commands

| Opcode | Name | Address | Data |
|---|---|---|---|
| `0x06` | Write enable | — | — |
| `0x04` | Write disable | — | — |
| `0x05` | Read status | — | 1 lane, repeats |
| `0x9F` | JEDEC id | — | 1 lane, 3 bytes |
| `0x03` | Read | 1 lane | 1 lane |
| `0xBB` | Fast read dual I/O | 2 lanes | 2 lanes, after mode byte + dummy |
| `0xEB` | Fast read quad I/O | 4 lanes | 4 lanes, after mode byte + dummy |
| `0x02` | Page program | 1 lane | 1 lane; needs WEL, sets WIP |
| `0x20` | Sector erase (4 KB) | 1 lane | — ; needs WEL, sets WIP |
| `0x66` / `0x99` | Reset enable / reset | — | — |

`RSTEN` arms a reset for the **next** command only; anything in between
cancels it, so a stray `0x99` cannot reset a device mid-operation.
`initialize()` issues the pair, so a test cannot inherit the write enable
latch from whatever ran before it.

Status register: bit 0 `WIP` (write in progress), bit 1 `WEL` (write enable
latch). `wait_ready()` polls it rather than assuming a fixed delay, which is
what a real controller must do.

## Bus signals

`QspiBus.from_entity(dut)` picks up `clk`, `csb` and `io`, plus `io_out` and
`io_oe`.

A simulator will not let a testbench drive an `inout` net, so the top level
splits the master's half into a value and a **per-lane** output enable:

```verilog
wire [3:0] io;
assign io[0] = io_oe[0] ? io_out[0] : 1'bz;
assign io[1] = io_oe[1] ? io_out[1] : 1'bz;
assign io[2] = io_oe[2] ? io_out[2] : 1'bz;
assign io[3] = io_oe[3] ? io_out[3] : 1'bz;
```

Per-lane, not bus-wide: in single-lane mode the master drives `io0` while
the device answers on `io1`.

Note also that `csb` is left uninitialised in `qspi_flash_test.v`. The model
frames transactions on chip-select edges, and an initialiser there races
cocotb's first write at time 0 — the edge is lost and the device never
starts. `initialize()` drives the sequence explicitly.

## Testing

Two suites, and the split matters:

```
make -C tests                      # against our own JEDEC model: 11 tests
make -C tests -f Makefile.interop  # against PicoSoC's spiflash.v: 5 tests
```

The interop suite drives
[`spiflash.v`](https://github.com/YosysHQ/picorv32) — a model this project
did not write — and checks the bytes against known `$readmemh` content.

That distinction earned its keep. Testing only against our own model proves
the driver and the model agree; it does not prove either is right. Driving
somebody else's model immediately found that the master was dropping the
first bit of every byte — our model had the same off-by-one assumption, so
the closed loop had been happily agreeing with itself.

## Layout

| Path | Contents |
|---|---|
| `cocotbext/qspi/qspi_flash.py` | `QspiFlash` — JEDEC command set, status polling |
| `cocotbext/qspi/qspi_master.py` | `QspiMaster` — byte transfers at 1/2/4 lanes |
| `cocotbext/qspi/qspi_bus.py` | `QspiBus` — signal bundle |
| `cocotbext/qspi/verilog/qspi_flash.v` | NOR flash model: WEL, WIP, page program, sector erase |
| `cocotbext/qspi/verilog/qspi_flash_test.v` | cocotb top level |
| `tests/reference/` | third-party model for interop (ISC, see its README) |

## Licence

MIT. `tests/reference/spiflash.v` is ISC, © Claire Xenia Wolf.
