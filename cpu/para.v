`define ysyx_22040383_width 63:0
`define ysyx_22040383_instr_width 31:0
`define ysyx_22040383_reg_width 4:0
`define ysyx_22040383_r_type_opcode 7'b0110011
`define ysyx_22040383_rw_type_opcode 7'b0111011
`define ysyx_22040383_i_type_opcode 7'b0010011
`define ysyx_22040383_iw_type_opcode 7'b0011011
`define ysyx_22040383_l_type_opcode 7'b0000011
`define ysyx_22040383_b_type_opcode 7'b1100011
`define ysyx_22040383_s_type_opcode 7'b0010011
`define ysyx_22040383_auipc_opcode 7'b0010111
`define ysyx_22040383_lui_opcode 7'b0110111
`define ysyx_22040383_jal_type_opcode 7'b1101111
`define ysyx_22040383_jalr_opcode 7'b1100111

`define ysyx_22040383_add_or_sub_or_mul 3'b000
// `define ysyx_22040383_sub 3'b000
`define ysyx_22040383_slt 3'b010
`define ysyx_22040383_sltu 3'b011

`define ysyx_22040383_xor_or_div 3'b100
// `define ysyx_22040383_sra 3'b101
`define ysyx_22040383_or_or_rem 3'b110
`define ysyx_22040383_and 3'b111

//j type empty .

//i type
`define ysyx_22040383_addi 3'b000
`define ysyx_22040383_slti 3'b010
`define ysyx_22040383_sltiu 3'b011
`define ysyx_22040383_xori 3'b100
`define ysyx_22040383_ori 3'b110
`define ysyx_22040383_andi 3'b111
`define ysyx_22040383_sllx 3'b001
`define ysyx_22040383_srlx_and_srax 3'b101
// `define ysyx_22040383_srai 3'b101
//stype 
`define ysyx_22040383_sb 3'b000
`define ysyx_22040383_sh 3'b001
`define ysyx_22040383_sw 3'b010
`define ysyx_22040383_sd 3'b011
//l type
`define ysyx_22040383_lb 3'b000
`define ysyx_22040383_lh 3'b001
`define ysyx_22040383_lw 3'b010
`define ysyx_22040383_lbu 3'b100
`define ysyx_22040383_lhu 3'b101
`define ysyx_22040383_ld 3'b011


//b type
`define ysyx_22040383_beq 3'b000
`define ysyx_22040383_bne 3'b001
`define ysyx_22040383_blt 3'b100
`define ysyx_22040383_bge 3'b101
`define ysyx_22040383_bltu 3'b110
`define ysyx_22040383_bgeu 3'b111



//********************alu
`define ysyx_22040383_alu_add 4'b0000
`define ysyx_22040383_alu_sl 4'b0001
`define ysyx_22040383_alu_sr 4'b0010
`define ysyx_22040383_alu_xor 4'b0011
`define ysyx_22040383_alu_or 4'b0100
`define ysyx_22040383_alu_and 4'b0101
`define ysyx_22040383_alu_sra 4'b0110
`define ysyx_22040383_alu_mul 4'b0111
`define ysyx_22040383_alu_div 4'b1000
`define ysyx_22040383_alu_rem 4'b1001