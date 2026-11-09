// Functional profile for Macronix MX25L3233F.
// This wrapper reuses the generic cocotbext-qspi NOR model; it is not the vendor RTL.
module m_flash_profile_mx25l3233f #(
    parameter integer PARA_MEM_DEPTH_BYTES = 4194304,
    parameter integer PARA_DUMMY_CYCLES = 8
) (
    input  wire       i_clk,
    input  wire       i_csb_n,
    inout  wire [3:0] io
);
    qspi_flash #(
        .MEM_DEPTH (PARA_MEM_DEPTH_BYTES),
        .DUMMY     (PARA_DUMMY_CYCLES),
        .ID0       (8'hC2),
        .ID1       (8'h20),
        .ID2       (8'h16)
    ) u_flash (
        .clk (i_clk),
        .csb (i_csb_n),
        .io  (io)
    );
endmodule
