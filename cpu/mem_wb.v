`include "para.v"
module mem_wb (
    input sys_clk,
    input sys_rst,
    input [4:0]mem_write_back_addr,
    input [`width] mem_write_back_data,
    output reg [4:0] wb_write_back_addr,
    output reg [`width] wb_write_back_data
);
    always @(posedge sys_clk) begin
        wb_write_back_addr<=mem_write_back_addr;
        wb_write_back_data<=mem_write_back_data;
    end
endmodule