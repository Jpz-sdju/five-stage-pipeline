`include "para.v"
module imm_extend (
    input [31:0] instruction,

    //serval signal
    input r_type,
    input i_type,
    input l_type,
    input s_type,
    input b_type,
    input j_type,
    input u_type,


    output reg [`WIDTH] extended_imm
);
    
    wire [`WIDTH] i_and_l_and_jalr_extend_imm = { {52{instruction[31]}} ,instruction[31:20] };
    wire [`WIDTH] s_extend_imm = { {52{instruction[31]}}, instruction[31:25], instruction[11:7] };   
    wire [`WIDTH] b_extend_imm = { {52{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };   
    wire [`WIDTH] lui_and_auipc_extend_imm = { {33{instruction[31]}} ,instruction[30:12], 12'b0 };//note:slli and srli appear not 
    wire [`WIDTH] jal_extend_imm = { {44{instruction[31]}} ,instruction[19:12] ,instruction[20] ,instruction[30:21] , 1'b0};
    
    wire [`WIDTH] i_type_shift_shamt = { 58'b0, instruction[25:20]};

    wire slli_srli_srai_shamt6 = (instruction[6:0] == `i_type_opcode) &&
    ((instruction[14:12] == `slli) || 
    instruction[14:12] == `srli_and_srai);

    always @(*) begin
        if (r_type) begin
            extended_imm=64'b0;
        end 
        else if(i_type || l_type)begin
            if (slli_srli_srai_shamt6) begin
                extended_imm = i_type_shift_shamt;
            end
            else
                extended_imm = i_and_l_and_jalr_extend_imm;
        end
        else if(s_type)
            extended_imm = s_extend_imm;
        else if(b_type)
            extended_imm = b_extend_imm;
        else if(j_type) begin
            if(instruction[6:0] == `jal_type_opcode)
                    extended_imm = jal_extend_imm;
            else
                    extended_imm = i_and_l_and_jalr_extend_imm;
        end
        else if(u_type)         //auipc and lui
                extended_imm = lui_and_auipc_extend_imm;
        else
                extended_imm =64'b0;
            
    end
    // assign extended_imm = i_type? i_and_l_extend_imm:32'b0;

endmodule