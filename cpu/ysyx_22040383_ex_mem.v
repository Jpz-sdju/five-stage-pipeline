`include "para.v"
module ysyx_22040383_ex_mem (input sys_clk,
               input sys_rst,
               input valid,
               input expr_mempr_is_write_dmem,
               input expr_mempr_is_write_rf,
               input [1:0]expr_mempr_wb_select,
               input [7:0] expr_mempr_write_width,
               input [`ysyx_22040383_width] ex_mempr_rs2_data,
               input [`ysyx_22040383_width] ex_mempr_alu_res,
               input [4:0] expr_mempr_rd,
               input [`ysyx_22040383_width] ex_mempr_pc_plus_4,
               input [`ysyx_22040383_width] expr_mempr_now_pc,
               input [`ysyx_22040383_instr_width] expr_mempr_instruction,
               input expr_mempr_stall,
               output reg mempr_mem_is_write_dmem,
               output reg mempr_wbpr_is_write_rf,
               output reg [1:0]mempr_mem_wb_select,
               output reg [7:0] mempr_mem_write_width,
               output reg [`ysyx_22040383_width] mempr_mem_rs2_data,
               output reg [`ysyx_22040383_width] mempr_mem_alu_res,
               output reg [4:0] mempr_wbpr_rd,
               output reg [`ysyx_22040383_width] mempr_mem_pc_plus_4,
               output reg [`ysyx_22040383_width] mempr_wbpr_now_pc,
               output reg [`ysyx_22040383_instr_width] mempr_wbpr_instruction,
               output reg mempr_wbpr_stall
               );
    always @(posedge sys_clk) begin
        mempr_mem_is_write_dmem <= expr_mempr_is_write_dmem;
        mempr_mem_wb_select     <= expr_mempr_wb_select;
        mempr_mem_write_width   <= expr_mempr_write_width;
        mempr_mem_rs2_data      <= ex_mempr_rs2_data;
        mempr_mem_alu_res       <= ex_mempr_alu_res;
        mempr_wbpr_rd           <= expr_mempr_rd;
        mempr_mem_pc_plus_4     <= ex_mempr_pc_plus_4;
        mempr_wbpr_now_pc      <= expr_mempr_now_pc;
        mempr_wbpr_stall        <= expr_mempr_stall;
        mempr_wbpr_is_write_rf  <= expr_mempr_is_write_rf;
        mempr_wbpr_instruction  <=expr_mempr_instruction;
    end
endmodule
