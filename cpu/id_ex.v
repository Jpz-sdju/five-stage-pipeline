`include "para.v"
module id_ex (
    input sys_clk,
    input sys_rst,
    input valid,
    
    input [`width] id_expr_final_a,      
    input [`width] id_expr_final_b,
    input [31:0] id_expr_pc_plus_4,
    //signals to MEM_EB
    input id_expr_is_write_dmem,
    input [4:0] id_expr_rd,
    input [1:0] id_expr_wb_select,
    input [7:0] id_expr_write_width,
    input [`width] id_expr_dmem_write_data,
    input id_expr_sub,
    input id_expr_slt_and_spin_off_signed,
    input id_expr_slt_and_spin_off_unsigned,
    input [2:0]id_expr_alu_op,
    input id_expr_word_op,
    input id_expr_pc_sel,         //control harazd!
    ////////////to exu/////////////////
    output reg [`width] expr_ex_final_a,      
    output reg [`width] expr_ex_final_b,      
    output reg [31:0] expr_ex_pc_plus_4,
    output reg [2:0]expr_ex_alu_op,
    output reg expr_ex_sub,
    output reg expr_ex_slt_and_spin_off_signed,
    output reg expr_ex_slt_and_spin_off_unsigned,
    output reg expr_ex_word_op,
    ///////////end od to exu//////////////
    //signareg ls to MEM_EB
    output reg expr_ex_is_write_dmem,
    output reg [1:0] expr_ex_wb_select,
    output reg [7:0] expr_ex_write_width,
    output reg [`width] expr_ex_dmem_write_data,
    output reg [4:0] expr_ex_rd,
    output reg expr_ex_pc_sel         //control harazd!

);
    always @(posedge sys_clk) begin
        expr_ex_final_a<= id_expr_final_a;     
        expr_ex_final_b<= id_expr_final_b;
        expr_ex_pc_plus_4<=id_expr_pc_plus_4;
        expr_ex_is_write_dmem<=id_expr_is_write_dmem;
        expr_ex_wb_select<=id_expr_wb_select;
        expr_ex_write_width<=id_expr_write_width;
        expr_ex_dmem_write_data<=id_expr_dmem_write_data;
        expr_ex_sub<=id_expr_sub;
        expr_ex_slt_and_spin_off_signed<=id_expr_slt_and_spin_off_signed;
        expr_ex_slt_and_spin_off_unsigned<=id_expr_slt_and_spin_off_unsigned;
        expr_ex_alu_op<=id_expr_alu_op;
        expr_ex_word_op<=id_expr_word_op;
        expr_ex_pc_sel<=id_expr_pc_sel;
        expr_ex_rd<=id_expr_rd;
    end
endmodule