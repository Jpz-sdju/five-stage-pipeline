`include "para.v"
module id_ex (
    input sys_clk,
    input sys_rst,
    
    input [`width] id_final_a,      
    input [`width] id_final_b,      
    //signals to MEM_EB
    input id_is_write_dmem,
    input [1:0] id_wb_select,
    input [7:0] id_write_width,
    input [`width] id_dmem_write_data,
    input id_sub,
    input id_slt_and_spin_off_signed,
    input id_slt_and_spin_off_unsigned,
    input [2:0]id_alu_op,
    input id_pc_sel,         //control harazd!
    ////////////to exu/////////////////
    output reg [`width] ex_final_a,      
    output reg [`width] ex_final_b,      
    output reg [2:0]ex_alu_op,
    output reg ex_sub,
    output reg ex_slt_and_spin_off_signed,
    output reg ex_slt_and_spin_off_unsigned,
    ///////////end od to exu//////////////
    //signareg ls to MEM_EB
    output reg ex_is_write_dmem,
    output reg [1:0] ex_wb_select,
    output reg [7:0] ex_write_width,
    output reg [`width] ex_dmem_write_data,
    output reg ex_pc_sel         //control harazd!

);
    always @(posedge sys_clk) begin
        ex_final_a<= id_final_a;     
        ex_final_b<= id_final_b;
        ex_is_write_dmem<=id_is_write_dmem;
        ex_wb_select<=id_wb_select;
        ex_write_width<=id_write_width;
        ex_dmem_write_data<=id_dmem_write_data;
        ex_sub<=id_sub;
        ex_slt_and_spin_off_signed<=id_slt_and_spin_off_signed;
        ex_slt_and_spin_off_unsigned<=id_slt_and_spin_off_unsigned;
        ex_alu_op<=id_alu_op;
        ex_pc_sel<=id_pc_sel;
    end
endmodule