`include "para.v"
module ysyx_22040383_id_ex (
    input sys_clk,
    input sys_rst,
    input invalid,
    
    input [`ysyx_22040383_width] id_expr_final_a,      
    input [`ysyx_22040383_width] id_expr_final_b,
    input [`ysyx_22040383_width] id_expr_pc_plus_4,
    input [`ysyx_22040383_width] idpr_expr_now_pc,
    input [`ysyx_22040383_instr_width] idpr_expr_instruction,
    //signals to MEM_EB
    input id_expr_is_write_dmem,
    input id_expr_is_write_rf,
    input [4:0] id_expr_rd,
    input [1:0] id_expr_wb_select,
    input [7:0] id_expr_write_width,
    input [`ysyx_22040383_width] id_expr_rs2_data,
    input id_expr_sub,
    input id_expr_slt_and_spin_off_signed,
    input id_expr_slt_and_spin_off_unsigned,
    input [3:0]id_expr_alu_op,
    input id_expr_word_op,
    input id_expr_stall,         //control harazd!
    ////////////to exu/////////////////
    output reg [`ysyx_22040383_width] expr_ex_final_a,      
    output reg [`ysyx_22040383_width] expr_ex_final_b,      
    output reg [`ysyx_22040383_width] expr_ex_pc_plus_4,
    output reg [`ysyx_22040383_instr_width] expr_mempr_instruction,
    output reg [3:0]expr_ex_alu_op,
    output reg expr_ex_sub,
    output reg expr_ex_slt_and_spin_off_signed,
    output reg expr_ex_slt_and_spin_off_unsigned,
    output reg expr_ex_word_op,
    ///////////end od to exu//////////////
    //signareg ls to MEM_EB
    output reg expr_ex_is_write_dmem,
    output reg expr_mempr_is_write_rf,
    output reg [1:0] expr_ex_wb_select,
    output reg [7:0] expr_ex_write_width,
    output reg [`ysyx_22040383_width] expr_ex_rs2_data,
    output reg [4:0] expr_mempr_rd,
    output reg expr_mempr_stall,         //control harazd!
    output reg [`ysyx_22040383_width] expr_mempr_now_pc

);
    always @(posedge sys_clk) begin
        if (~invalid) begin
        expr_ex_final_a<= id_expr_final_a;     
        expr_ex_final_b<= id_expr_final_b;
        expr_ex_pc_plus_4<=id_expr_pc_plus_4;
        expr_ex_is_write_dmem<=id_expr_is_write_dmem;
        expr_ex_wb_select<=id_expr_wb_select;
        expr_ex_write_width<=id_expr_write_width;
        expr_ex_rs2_data<=id_expr_rs2_data;
        expr_ex_sub<=id_expr_sub;
        expr_ex_slt_and_spin_off_signed<=id_expr_slt_and_spin_off_signed;
        expr_ex_slt_and_spin_off_unsigned<=id_expr_slt_and_spin_off_unsigned;
        expr_ex_alu_op<=id_expr_alu_op;
        expr_ex_word_op<=id_expr_word_op;
        expr_mempr_stall<=id_expr_stall;
        expr_mempr_rd<=id_expr_rd;
        expr_mempr_now_pc<=idpr_expr_now_pc;
        expr_mempr_is_write_rf<=id_expr_is_write_rf;
        expr_mempr_instruction<=idpr_expr_instruction;
        end
        else begin
        expr_ex_final_a<= 0;     
        expr_ex_final_b<= 0;
        expr_ex_pc_plus_4<=0;
        expr_ex_is_write_dmem<=0;
        expr_ex_wb_select<=0;
        expr_ex_write_width<=0;
        expr_ex_rs2_data<=0;
        expr_ex_sub<=0;
        expr_ex_slt_and_spin_off_signed<=0;
        expr_ex_slt_and_spin_off_unsigned<=0;
        expr_ex_alu_op<=0;
        expr_ex_word_op<=0;
        expr_mempr_stall<=1;
        expr_mempr_rd<=0;
        expr_mempr_now_pc<=0;
        expr_mempr_is_write_rf<=0;
        expr_mempr_instruction<=0;
            
        end
    end
endmodule