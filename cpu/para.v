`define WIDTH 63:0
`define INS_WIDTH 31:0
`define r_type_opcode 7'b0110011
`define i_type_opcode 7'b0010011
`define l_type_opcode 7'b0000011
`define b_type_opcode 7'b1100011
`define s_type_opcode 7'b0010011
`define auipc_opcode 7'b0010111
`define lui_opcode 7'b0110111
`define jal_type_opcode 7'b1101111
`define jalr_opcode 7'b1100111

`define add_or_sub 3'b000
// `define sub 3'b000
`define sll 3'b001
`define slt 3'b010
`define sltu 3'b011

`define xor 3'b100
`define srl_and_sra 3'b101
// `define sra 3'b101
`define or 3'b110
`define and 3'b111

//j type empty .

//i type
`define addi 3'b000
`define slti 3'b010
`define sltiu 3'b011
`define xori 3'b100
`define ori 3'b110
`define andi 3'b111
`define slli 3'b001
`define srli_and_srai 3'b101
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
`define alu_add 3'b000
// `define alu_sub 3'b001
`define alu_sl 3'b001
`define alu_sr 3'b010
`define alu_xor 3'b011
`define alu_or 3'b100
`define alu_and 3'b101
`define alu_sra 3'b110