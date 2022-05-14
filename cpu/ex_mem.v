`include "para.v"
module ex_mem (
    input sys_clk,
    input sys_rst,
    input valid,

    input ex_mempr_is_write_dmem,
    input [1:0]ex_mempr_wb_select,
    input [7:0] ex_mempr_write_width,
    input [`width] ex_mempr_dmem_write_data,
    output reg mempr_mem_is_write_dmem,
    output reg [1:0]mempr_mem_wb_select,
    output reg [7:0] mempr_mem_write_width,
    output reg [`width] mempr_mem_dmem_write_data
);
    always @(posedge sys_clk) begin
         mempr_mem_is_write_dmem<=ex_mempr_is_write_dmem;
         mempr_mem_wb_select<=ex_mempr_wb_select;
         mempr_mem_write_width<=ex_mempr_write_width;
         mempr_mem_dmem_write_data<=ex_mempr_dmem_write_data;
    end
endmodule