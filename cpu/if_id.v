`include "para.v"
module if_id (
    input sys_clk,
    input sys_rst,
    input valid,
    
    input [`width] if_idpr_now_pc,
    input [`width] if_idpr_pc_plus_4,
    input [`width] if_idpr_instruction,
    output reg [`width] idpr_id_now_pc,
    output reg [`width] idpr_id_pc_plus_4,
    output reg [`width] idpr_id_instruction
);
    
    always @(posedge sys_clk) begin
        idpr_id_now_pc<=if_idpr_now_pc;
        idpr_id_pc_plus_4<=if_idpr_pc_plus_4;
        idpr_id_instruction<=if_idpr_instruction;
    end
endmodule