// QSPI NOR flash slave model, JEDEC command set.
//
// Behaves like a small serial NOR flash (W25Q / S25FL family): SPI mode 0,
// most-significant bit first, 24-bit addresses, and a command set where the
// opcode itself is always single-lane and only the address, mode byte and
// data widen to two or four lanes.
//
//   0x06 WREN   set the write enable latch
//   0x04 WRDI   clear it
//   0x05 RDSR   read status: bit0 WIP (busy), bit1 WEL
//   0x9F RDID   three JEDEC id bytes
//   0xAB RDP    release from deep power-down
//   0xB9 DP     enter deep power-down
//   0x03 READ   addr(1) data(1)
//   0xBB QIOR2  addr(2) mode(2) dummy data(2)
//   0xEB QIOR4  addr(4) mode(4) dummy data(4)
//   0x02 PP     page program, addr(1) data(1); needs WEL, sets WIP
//   0x20 SE     4 KB sector erase, addr(1); needs WEL, sets WIP
//
// Programming can only clear bits, as NOR flash does -- a byte must be
// erased before it can be rewritten. Program and erase assert WIP for a
// simulated duration, so a controller has to poll RDSR rather than assume
// the write landed instantly.

`timescale 1ns/1ps

module qspi_flash #(
    parameter MEM_DEPTH   = 65536,
    parameter SECTOR_SIZE = 4096,
    parameter PAGE_SIZE   = 256,
    parameter PROGRAM_NS  = 1000,
    parameter ERASE_NS    = 5000,
    parameter DUMMY       = 8,      // dummy cycles after the mode byte
    parameter [7:0] ID0   = 8'hEF,  // manufacturer
    parameter [7:0] ID1   = 8'h40,  // memory type
    parameter [7:0] ID2   = 8'h18   // capacity
)(
    input  wire       clk,
    input  wire       csb,          // active low chip select
    inout  wire [3:0] io
);

    localparam [7:0] CMD_WREN  = 8'h06,
                     CMD_WRDI  = 8'h04,
                     CMD_RDSR  = 8'h05,
                     CMD_RDID  = 8'h9F,
                     CMD_RDP   = 8'hAB,
                     CMD_DP    = 8'hB9,
                     CMD_READ  = 8'h03,
                     CMD_QIOR2 = 8'hBB,
                     CMD_QIOR4 = 8'hEB,
                     CMD_PP    = 8'h02,
                     CMD_SE    = 8'h20,
                     CMD_RSTEN = 8'h66,
                     CMD_RST   = 8'h99;

    reg [7:0]  memory [0:MEM_DEPTH-1];

    reg [7:0]  buffer;
    integer    bitcount;
    integer    bytecount;
    integer    dummycount;
    reg [7:0]  cmd;
    reg [23:0] addr;

    reg [2:0]  lanes;       // lanes for the phase in progress
    reg        driving;     // device is sourcing the bus
    reg [3:0]  dout;

    reg        wel;         // write enable latch
    reg        rst_enabled; // RSTEN must immediately precede RST
    reg        was_rst_enabled;
    reg        wip;         // write in progress
    reg        powered_up;

    // Page program buffer: collected during the transaction, committed when
    // chip select rises, as a real part does.
    reg [7:0]  pp_data [0:PAGE_SIZE-1];
    integer    pp_count;

    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) memory[i] = 8'hFF;
        bitcount   = 0;
        bytecount  = 0;
        dummycount = 0;
        lanes      = 1;
        driving    = 0;
        buffer     = 0;
        cmd        = 0;
        addr       = 0;
        wel        = 0;
        wip        = 0;
        rst_enabled = 0;
        was_rst_enabled = 0;
        powered_up = 1;   // start usable; 0xB9/0xAB still work
        pp_count   = 0;
    end

    assign io[0] = driving ? dout[0] : 1'bz;
    assign io[1] = (driving && lanes >= 2) ? dout[1] :
                   (driving && lanes == 1) ? dout[1] : 1'bz;
    assign io[2] = (driving && lanes == 4) ? dout[2] : 1'bz;
    assign io[3] = (driving && lanes == 4) ? dout[3] : 1'bz;

    wire [7:0] status = {6'b0, wel, wip};

    // ── byte received / next byte to send ────────────────────────────
    task handle_byte;
        begin
            if (bytecount == 1) begin
                cmd = buffer;
                // RSTEN arms a reset for the *next* command only. Any other
                // command clears the arming, so a stray RST cannot reset a
                // device mid-operation.
                was_rst_enabled = rst_enabled;
                rst_enabled = (cmd == CMD_RSTEN);
                case (cmd)
                    CMD_WREN: if (!wip) wel = 1'b1;
                    CMD_WRDI: wel = 1'b0;
                    CMD_RST: if (was_rst_enabled) wel = 1'b0;
                    CMD_RDP:  powered_up = 1'b1;
                    CMD_DP:   powered_up = 1'b0;
                    CMD_QIOR2: lanes = 2;   // widens straight after the opcode
                    CMD_QIOR4: lanes = 4;
                    CMD_RDSR: buffer = status;
                    CMD_RDID: buffer = ID0;
                    default: ;
                endcase
            end else begin
                case (cmd)
                    CMD_RDSR: buffer = status;   // repeats while clocked
                    CMD_RDID: buffer = (bytecount == 2) ? ID1 :
                                       (bytecount == 3) ? ID2 : 8'h00;

                    CMD_READ: begin
                        if (bytecount == 2) addr[23:16] = buffer;
                        if (bytecount == 3) addr[15:8]  = buffer;
                        if (bytecount == 4) addr[7:0]   = buffer;
                        if (bytecount >= 4 && powered_up && !wip) begin
                            buffer = memory[addr % MEM_DEPTH];
                            addr = addr + 1;
                        end
                    end

                    CMD_QIOR2, CMD_QIOR4: begin
                        if (bytecount == 2) addr[23:16] = buffer;
                        if (bytecount == 3) addr[15:8]  = buffer;
                        if (bytecount == 4) addr[7:0]   = buffer;
                        if (bytecount == 5) dummycount = DUMMY;  // mode byte
                        if (bytecount >= 5 && powered_up && !wip) begin
                            buffer = memory[addr % MEM_DEPTH];
                            addr = addr + 1;
                        end
                    end

                    CMD_PP: begin
                        if (bytecount == 2) addr[23:16] = buffer;
                        if (bytecount == 3) addr[15:8]  = buffer;
                        if (bytecount == 4) addr[7:0]   = buffer;
                        if (bytecount >= 5 && pp_count < PAGE_SIZE) begin
                            pp_data[pp_count] = buffer;
                            pp_count = pp_count + 1;
                        end
                    end

                    CMD_SE: begin
                        if (bytecount == 2) addr[23:16] = buffer;
                        if (bytecount == 3) addr[15:8]  = buffer;
                        if (bytecount == 4) addr[7:0]   = buffer;
                    end

                    default: ;
                endcase
            end
        end
    endtask

    // ── chip select ──────────────────────────────────────────────────
    integer p, base, s;
    always @(csb) begin
        if (csb) begin
            // Rising edge commits whatever the transaction asked for.
            if (cmd == CMD_PP && wel && !wip && pp_count > 0) begin
                wip = 1'b1;
                wel = 1'b0;
                for (p = 0; p < pp_count; p = p + 1) begin
                    // addr holds where the program started -- unlike a read,
                    // a page program does not advance it as bytes arrive.
                    // Programming clears bits only; erase is what sets them.
                    base = (addr + p) % MEM_DEPTH;
                    memory[base] = memory[base] & pp_data[p];
                end
                #(PROGRAM_NS) wip = 1'b0;
            end else if (cmd == CMD_SE && wel && !wip) begin
                wip = 1'b1;
                wel = 1'b0;
                base = (addr / SECTOR_SIZE) * SECTOR_SIZE;
                for (s = 0; s < SECTOR_SIZE; s = s + 1)
                    if (base + s < MEM_DEPTH) memory[base + s] = 8'hFF;
                #(ERASE_NS) wip = 1'b0;
            end
        end
    end

    // Reset the framing whenever chip select moves.
    always @(csb) begin
        bitcount   = 0;
        bytecount  = 0;
        dummycount = 0;
        lanes      = 1;
        driving    = 0;
        buffer     = 0;
        if (!csb) begin
            cmd      = 0;
            pp_count = 0;
        end
    end

    // ── device drives while the clock is low ─────────────────────────
    //
    // Combinational rather than sensitive to clk and csb alone. Today this
    // model is single transfer rate, so state changes on a rising edge and
    // this re-evaluates on the following falling one -- there is always an
    // edge in between. That gap disappears in DTR, where the device must
    // drive on both edges, and the first byte would read as released. The
    // octal models hit exactly that; fixing it here keeps the bug from
    // reappearing if this one ever gains a DTR mode.
    always @(*) begin
        if (!csb && !clk && dummycount == 0) begin
            case (cmd)
                CMD_RDSR, CMD_RDID: if (bytecount >= 1) begin
                    driving = 1; dout[1] = buffer[7];
                end
                CMD_READ: if (bytecount >= 4) begin
                    driving = 1; dout[1] = buffer[7];
                end
                CMD_QIOR2: if (bytecount >= 5) begin
                    driving = 1; dout[1:0] = buffer[7:6];
                end
                CMD_QIOR4: if (bytecount >= 5) begin
                    driving = 1; dout = buffer[7:4];
                end
                default: driving = 0;
            endcase
        end else if (csb || dummycount != 0) begin
            driving = 0;
        end
    end

    // ── sample the master while shifting out ─────────────────────────
    always @(posedge clk) begin
        if (!csb) begin
            if (dummycount > 0) begin
                dummycount = dummycount - 1;
            end else begin
                case (lanes)
                    1: buffer = {buffer[6:0], io[0]};
                    2: buffer = {buffer[5:0], io[1], io[0]};
                    4: buffer = {buffer[3:0], io[3], io[2], io[1], io[0]};
                    default: buffer = {buffer[6:0], io[0]};
                endcase
                bitcount = bitcount + lanes;
                if (bitcount >= 8) begin
                    bitcount  = 0;
                    bytecount = bytecount + 1;
                    handle_byte;
                end
            end
        end
    end

endmodule
