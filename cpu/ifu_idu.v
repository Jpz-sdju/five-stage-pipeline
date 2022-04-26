`include "para.v"
module ifu_idu (
    input sys_clk,
    input [`WIDTH] if_now_pc,
    input [`WIDTH] if_pc_plus_4,
    input [`INS_WIDTH] if_instruction,
    output reg [`WIDTH] id_now_pc,
    output reg [`WIDTH] id_pc_plus_4,
    output reg [`INS_WIDTH] id_instruction
);
    
    always @(posedge sys_clk) begin
        id_now_pc<=if_now_pc;
        id_pc_plus_4<=if_pc_plus_4;
        id_instruction<=if_instruction;
    end
endmodule