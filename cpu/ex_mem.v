`include "para.v"
module ex_mem (
    input sys_clk,
    input sys_rst,
    input valid,

    input ex_is_write_dmem,
    input [1:0]ex_wb_select,
    input [7:0] ex_write_width,
    input [`width] ex_dmem_write_data,
    output reg mem_is_write_dmem,
    output reg [1:0]mem_wb_select,
    output reg [7:0] mem_write_width,
    output reg [`width] mem_dmem_write_data
);
    always @(posedge sys_clk) begin
         mem_is_write_dmem<=ex_is_write_dmem;
         mem_wb_select<=ex_wb_select;
         mem_write_width<=ex_write_width;
         mem_dmem_write_data<=ex_dmem_write_data;
    end
endmodule