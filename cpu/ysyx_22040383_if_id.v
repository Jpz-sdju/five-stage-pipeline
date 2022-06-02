`include "para.v"
module ysyx_22040383_if_id (
    input sys_clk,
    input sys_rst,
    input invalid,
    input stall_id_reg,
    input [`ysyx_22040383_width] if_idpr_now_pc,
    input [`ysyx_22040383_width] if_idpr_pc_plus_4,
    input [31:0] if_idpr_instruction,
    output reg [`ysyx_22040383_width] idpr_id_now_pc,
    output reg [`ysyx_22040383_width] idpr_id_pc_plus_4,
    output reg [31:0] idpr_id_instruction
);
    always @(posedge sys_clk) begin
        if (sys_rst) begin
            idpr_id_now_pc<=0;
            idpr_id_pc_plus_4<=0;
            idpr_id_instruction<=0;
        end
        else begin
            if (~stall_id_reg && ~invalid) begin
                idpr_id_now_pc<=if_idpr_now_pc;
                idpr_id_pc_plus_4<=if_idpr_pc_plus_4;
                idpr_id_instruction<=if_idpr_instruction;
            end
            else if (invalid && ~stall_id_reg) begin
                idpr_id_now_pc<=0;
                idpr_id_pc_plus_4<=0;
                idpr_id_instruction<=0;
            end
        end
        
    end
endmodule