// Functional profile for Infineon (Spansion) S25FL128S.
// This wrapper reuses the generic cocotbext-qspi NOR model; it is not the vendor RTL.
module m_flash_profile_s25fl128s #(
    parameter integer PARA_MEM_DEPTH_BYTES = 16777216,
    parameter integer PARA_DUMMY_CYCLES = 8
) (
    input  wire       i_clk,
    input  wire       i_csb_n,
    inout  wire [3:0] io
);
    qspi_flash #(
        .MEM_DEPTH (PARA_MEM_DEPTH_BYTES),
        .DUMMY     (PARA_DUMMY_CYCLES),
        .ID0       (8'h01),
        .ID1       (8'h20),
        .ID2       (8'h18)
    ) u_flash (
        .clk (i_clk),
        .csb (i_csb_n),
        .io  (io)
    );
endmodule
