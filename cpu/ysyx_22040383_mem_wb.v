`include "para.v"
module ysyx_22040383_mem_wb (
    input sys_clk,
    input sys_rst,
    input valid,
    
    input [`ysyx_22040383_width] mem_wbpr_write_back_data,
    input [4:0]mem_wbpr_write_back_addr,
    input [`ysyx_22040383_width] mempr_wbpr_now_pc,
    input mempr_wbpr_stall,
    input mempr_wbpr_is_write_rf,
    input [`ysyx_22040383_instr_width] mempr_wbpr_instruction,
    output reg [`ysyx_22040383_width] wbpr_wb_write_back_data,
    output reg [4:0] wbpr_wb_write_back_addr,
    output reg [`ysyx_22040383_width] wbpr_wb_now_pc,
    output reg [`ysyx_22040383_instr_width] wbpr_wb_instruction,
    output reg wbpr_wb_stall,
    output reg wbpr_wb_is_write_rf
);
    always @(posedge sys_clk) begin
        wbpr_wb_write_back_addr<=mem_wbpr_write_back_addr;
        wbpr_wb_write_back_data<=mem_wbpr_write_back_data;
        wbpr_wb_now_pc<=mempr_wbpr_now_pc;
        wbpr_wb_instruction <=mempr_wbpr_instruction;
        wbpr_wb_stall <= mempr_wbpr_stall;
        wbpr_wb_is_write_rf <= mempr_wbpr_is_write_rf;
    end
endmodule