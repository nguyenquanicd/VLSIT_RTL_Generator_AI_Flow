// Functional profile for Winbond W25Q16JV.
// This wrapper reuses the generic cocotbext-qspi NOR model; it is not the vendor RTL.
module m_flash_profile_w25q16jv #(
    parameter integer PARA_MEM_DEPTH_BYTES = 2097152,
    parameter integer PARA_DUMMY_CYCLES = 8
) (
    input  wire       i_clk,
    input  wire       i_csb_n,
    inout  wire [3:0] io
);
    qspi_flash #(
        .MEM_DEPTH (PARA_MEM_DEPTH_BYTES),
        .DUMMY     (PARA_DUMMY_CYCLES),
        .ID0       (8'hEF),
        .ID1       (8'h40),
        .ID2       (8'h15)
    ) u_flash (
        .clk (i_clk),
        .csb (i_csb_n),
        .io  (io)
    );
endmodule
