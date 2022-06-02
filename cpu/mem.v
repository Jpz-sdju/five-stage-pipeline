`include "para.v"
module mem (
    input sys_clk,
    input sys_rst,
    input [1:0] wb_select,
    input [`width] pc_plus_4,
    input [`width] read_addr,
    input [`width] alu_res,
    input [`width] rs2_data,
    input [7:0] write_width,
    input write_enable,
    output reg [`width] unprocess_data
);
reg [`width] dmem_data;
wire [`width] dpic_data;

MuxKey #(4,2,64) plus_4_or_more(
        unprocess_data,
        wb_select,
        {
            2'b00, alu_res,
            2'b01, dmem_data,
            2'b10, pc_plus_4,
            2'b11, alu_res  //not used
        }
    );
endmodule