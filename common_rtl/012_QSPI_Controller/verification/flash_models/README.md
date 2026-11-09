# QSPI XIP Flash Model Pack

## Contents

This directory contains one permissively licensed, generic SPI NOR behavioral model and ten device-profile wrappers for representative parts. The profiles make the model return a selected JEDEC ID and use the corresponding nominal storage depth. They are **not ten independent vendor RTL models** and are not silicon-qualified models.

The upstream model is `cocotbext-qspi` v0.2.0, kept with its MIT license and original README under `opensource/cocotbext-qspi-v0.2.0/`. `profiles/` contains one wrapper per part and `profile_catalog.csv` lists the nominal capacity and JEDEC ID.

## Protocol coverage

The generic model supports SPI mode 0 and a small NOR command set, including `0x03` 1-1-1 read, `0xBB` 1-2-2 read, `0xEB` 1-4-4 read, JEDEC ID, status read, write enable, page program, sector erase, and deep-power-down entry/exit. This is useful for checking the QSPI controller's memory-mapped read/XIP transaction flow with a basic quad-I/O flash response.

The model does not implement vendor-specific status/configuration registers, QE setup policy, SFDP, 4-byte addressing, QPI 4-4-4, all supported read opcodes, vendor timing limits, nor a persistent continuous-read/XIP state. Its program/erase delays are simulation placeholders. It must not be used to claim that the controller is compatible with every listed physical part. In particular, it is **not sufficient** to verify QPI 4-4-4 or per-vendor boot configuration.

To reduce simulator memory during a quick run, override a profile's `PARA_MEM_DEPTH_BYTES` parameter with a smaller power-of-two test window. Keep the default value for address-range checks up to the profile's nominal capacity. The model has a 24-bit internal address and therefore this pack intentionally includes only parts up to 128 Mbit / 16 MiB.

## Profiles

| Vendor | Part profile | Nominal density | JEDEC ID | Wrapper module |
|---|---|---:|---|---|
| Winbond | W25Q16JV | 16 Mbit | `EF 40 15` | `m_flash_profile_w25q16jv` |
| Winbond | W25Q32JV | 32 Mbit | `EF 40 16` | `m_flash_profile_w25q32jv` |
| Winbond | W25Q64JV | 64 Mbit | `EF 40 17` | `m_flash_profile_w25q64jv` |
| Winbond | W25Q128JV | 128 Mbit | `EF 40 18` | `m_flash_profile_w25q128jv` |
| Macronix | MX25L3233F | 32 Mbit | `C2 20 16` | `m_flash_profile_mx25l3233f` |
| Macronix | MX25L6433F | 64 Mbit | `C2 20 17` | `m_flash_profile_mx25l6433f` |
| Macronix | MX25L12835F | 128 Mbit | `C2 20 18` | `m_flash_profile_mx25l12835f` |
| Micron | N25Q064A | 64 Mbit | `20 BB 17` | `m_flash_profile_n25q064a` |
| Micron | N25Q128A | 128 Mbit | `20 BA 18` | `m_flash_profile_n25q128a` |
| Infineon / Spansion | S25FL128S | 128 Mbit | `01 20 18` | `m_flash_profile_s25fl128s` |

The JEDEC identifiers and capacities are representative database values; confirm the exact suffix, revision and extended-ID bytes against the selected device's datasheet before using a profile as a configuration requirement.

## Example hookup

```systemverilog
m_flash_profile_w25q64jv #(
    .PARA_MEM_DEPTH_BYTES (8 * 1024 * 1024),
    .PARA_DUMMY_CYCLES    (8)
) u_flash_model (
    .i_clk   (i_clk_spi),
    .i_csb_n (o_flash_csb_n),
    .io      (flash_io)
);
```

The upstream model initializes its storage bytes to `8'hFF`. For deterministic XIP data checks, preload `u_flash_model.u_flash.memory[...]` from the testbench. Keep the existing QSPI controller testbench responsible for AXI transactions and serial clock/CS timing.

## Vendor model availability

The manufacturers also publish exact Verilog models, but retrieval is not fully open:

- Winbond lists per-part Verilog archives, but the download flow requires acceptance of its product license and email verification. No account, email submission, or one-time code was used in assembling this pack.
- Macronix lists per-part models on its official support site. The site presented an expired TLS certificate to the local download client, so certificate validation was not disabled.
- Infineon model downloads are gated behind login.

If exact silicon-model validation is needed, obtain the vendor archives through an authorized account and keep each archive under its own vendor terms. Do not replace the generic profiles with these profiles in signoff claims.

## Sources

- Upstream generic model and license: [JitheshVijay/cocotbext-qspi v0.2.0](https://github.com/JitheshVijay/cocotbext-qspi/tree/v0.2.0)
- Winbond Verilog model listing: [Winbond Documentation](https://www.winbond.com/hq/support/documentation/?__locale=en&line=%2Fproduct%2Fcode-storage-flash%2Findex.html&family=%2Fproduct%2Fcode-storage-flash%2Fqspi-nor%2Findex.html&category=%2F.categories%2Fresources%2Fverilog-model%2F&pno=)
- Macronix Serial NOR model listing: [Macronix Technical Documentation](https://www.macronix.com/en-us/support/technical-documentation/Pages/Serial-NOR-Flash.aspx)
- Device identification cross-check: [Linux SPI-NOR Micron/Spansion table](https://github.com/torvalds/linux/blob/master/drivers/mtd/spi-nor/micron-st.c), [Linux SPI-NOR Winbond table](https://github.com/torvalds/linux/blob/master/drivers/mtd/spi-nor/winbond.c), and [flashrom Macronix table](https://github.com/flashrom/flashrom/blob/main/flashchips/macronix.c).
