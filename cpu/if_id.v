`include "para.v"
module if_id (
    input sys_clk,
    input sys_rst,
    input valid,
    
    input [`width] if_now_pc,
    input [`width] if_pc_plus_4,
    input [`width] if_instruction,
    output reg [`width] id_now_pc,
    output reg [`width] id_pc_plus_4,
    output reg [`width] id_instruction
);
    
    always @(posedge sys_clk) begin
        id_now_pc<=if_now_pc;
        id_pc_plus_4<=if_pc_plus_4;
        id_instruction<=if_instruction;
    end
endmodule