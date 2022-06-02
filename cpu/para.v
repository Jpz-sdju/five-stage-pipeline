`define width 63:0
`define instr_width 31:0
`define reg_width 4:0
`define r_type_opcode 7'b0110011
`define rw_type_opcode 7'b0111011
`define i_type_opcode 7'b0010011
`define iw_type_opcode 7'b0011011
`define l_type_opcode 7'b0000011
`define b_type_opcode 7'b1100011
`define s_type_opcode 7'b0010011
`define auipc_opcode 7'b0010111
`define lui_opcode 7'b0110111
`define jal_type_opcode 7'b1101111
`define jalr_opcode 7'b1100111

`define add_or_sub_or_mul 3'b000
// `define sub 3'b000
`define slt 3'b010
`define sltu 3'b011

`define xor_or_div 3'b100
// `define sra 3'b101
`define or_or_rem 3'b110
`define and 3'b111

//j type empty .

//i type
`define addi 3'b000
`define slti 3'b010
`define sltiu 3'b011
`define xori 3'b100
`define ori 3'b110
`define andi 3'b111
`define sllx 3'b001
`define srlx_and_srax 3'b101
// `define srai 3'b101
//stype 
`define sb 3'b000
`define sh 3'b001
`define sw 3'b010
`define sd 3'b011
//l type
`define lb 3'b000
`define lh 3'b001
`define lw 3'b010
`define lbu 3'b100
`define lhu 3'b101
`define ld 3'b011


//b type
`define beq 3'b000
`define bne 3'b001
`define blt 3'b100
`define bge 3'b101
`define bltu 3'b110
`define bgeu 3'b111



//********************alu
`define alu_add 4'b0000
`define alu_sl 4'b0001
`define alu_sr 4'b0010
`define alu_xor 4'b0011
`define alu_or 4'b0100
`define alu_and 4'b0101
`define alu_sra 4'b0110
`define alu_mul 4'b0111
`define alu_div 4'b1000
`define alu_rem 4'b1001