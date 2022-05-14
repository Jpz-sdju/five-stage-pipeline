`include "para.v"
module mem_wb (
    input sys_clk,
    input sys_rst,
    input valid,
    
    input [4:0]mem_wbpr_write_back_addr,
    input [`width] mem_wbpr_write_back_data,
    output reg [4:0] wbpr_wb_write_back_addr,
    output reg [`width] wbpr_wb_write_back_data
);
    always @(posedge sys_clk) begin
        wbpr_wb_write_back_addr<=mem_wbpr_write_back_addr;
        wbpr_wb_write_back_data<=mem_wbpr_write_back_data;
    end
endmodule