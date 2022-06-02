`include "para.v"
module ysyx_22040383_imm_extend (
    input [31:0] instruction,

    output reg [`ysyx_22040383_width] extended_imm
);
    wire [6:0] opcode = instruction[6:0];
    wire rw_type= opcode == `ysyx_22040383_rw_type_opcode;
    wire iw_type= opcode == `ysyx_22040383_iw_type_opcode;
    wire r_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]) ||(rw_type);     //0110011
    wire i_type = (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]) ||(iw_type);     //0010011
    wire l_type = (~opcode[6]&~opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);
    wire j_type = ( opcode[6]& opcode[5]&~opcode[4]& opcode[3]& opcode[2]& opcode[1]& opcode[0]) | ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //jal and jalr
    wire b_type = ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //1100011
    wire s_type = (~opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //0100011
    wire u_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]) | (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //


    
    wire [`ysyx_22040383_width] i_and_l_and_jalr_extend_imm = { {52{instruction[31]}} ,instruction[31:20] };
    wire [`ysyx_22040383_width] jal_extend_imm = { {44{instruction[31]}} ,instruction[19:12] ,instruction[20] ,instruction[30:21] , 1'b0};
    wire [`ysyx_22040383_width] b_extend_imm = { {52{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };   
    wire [`ysyx_22040383_width] s_extend_imm = { {52{instruction[31]}}, instruction[31:25], instruction[11:7] };   
    wire [`ysyx_22040383_width] lui_and_auipc_extend_imm = { {33{instruction[31]}} ,instruction[30:12], 12'b0 };//note:slli and srli appear not 
    
    wire [`ysyx_22040383_width] i_type_shift_shamt = { 58'b0, instruction[25:20]};

    wire slli_srli_srai_shamt6 = (instruction[6:0] == `ysyx_22040383_i_type_opcode ||iw_type ) &&
    ((instruction[14:12] == `ysyx_22040383_sllx) || 
    instruction[14:12] == `ysyx_22040383_srlx_and_srax);

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
            if(instruction[6:0] == `ysyx_22040383_jal_type_opcode)
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