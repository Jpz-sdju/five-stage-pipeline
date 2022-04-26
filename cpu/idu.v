`include "para.v"
module idu (
    input sys_clk,
    input sys_rst,
    input [31:0] instruction,
    input [`WIDTH] now_pc,        //signal to mux that across regfile and alu's b port

    input [`WIDTH] pc_plus_4,
    input [`WIDTH] write_back_data,
    output [`WIDTH] final_a,      //oprend a to alu
    output [`WIDTH] final_b,      //oprend b to alu
    //signals to MEM_EB
    output is_write_dmem,
    output reg [1:0] wb_select,
    output reg [7:0] write_width,

    output [`WIDTH] dmem_write_data,
    output sub,
    output slt_and_spin_off_signed,
    output slt_and_spin_off_unsigned,
    output reg [2:0]alu_op,
    output reg pc_sel,              //pc_sel to if
    output ebreak
);




    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    // reg [4:0] rd;
    // always @(posedge sys_clk) begin
    //     rd <= instruction [11:7];
    // end

    wire [4:0] rd = instruction[11:7];

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire is_rs1_pc;
    wire is_rs2_imm;
    //mux data 
    wire [`WIDTH] register_data1;
    wire [`WIDTH] register_data2;
    wire [`WIDTH] extended_imm;

    assign dmem_write_data = register_data2;
    //ebreak signal
    assign ebreak = ( opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);

    // wire [`WIDTH] write_back_data;

    wire r_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //0110011
    wire i_type = (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //0010011
    wire l_type = (~opcode[6]&~opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);
    wire j_type = ( opcode[6]& opcode[5]&~opcode[4]& opcode[3]& opcode[2]& opcode[1]& opcode[0]) | ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //jal and jalr
    wire b_type = ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //1100011
    wire s_type = (~opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //0100011
    wire u_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]) | (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //

    assign is_write_dmem = s_type;      //only in s type,dmem should be wrote.


    //sinnals for alu to optimize 
    assign sub = (r_type && funct3 == 3'b000 && funct7 == 7'b0100000);
    assign slt_and_spin_off_signed = (r_type || i_type) && (funct3 == 3'b010 );
    assign slt_and_spin_off_unsigned = (r_type || i_type)&&(funct3 == 3'b011);

//*********************final a and final b choose******************

    assign is_rs1_pc = (j_type&&opcode==`jal_type_opcode)||(opcode==`auipc_opcode)||(b_type);

    // always @(*) begin           //final a choose
    //     if(j_type)begin
    //         if(opcode == `jal_type_opcode )
    //             is_rs1_pc = 1'b1;
    //         else is_rs1_pc=1'b0;
    //     end 
    //     else if(opcode == `auipc_opcode)
    //         is_rs1_pc =1'b1;
    //     else if (b_type) begin
    //         is_rs1_pc =1'b1;
    //     end
    //     else is_rs1_pc =1'b0;
    // end
    assign is_rs2_imm = ~r_type;    //final b choose,only when ins is r type, rs2 is register.
    MuxKey #(2,1,64) rs1_or_pc(
        final_a,
        is_rs1_pc,
        {
            1'b0, register_data1,
            1'b1, now_pc
        }
    );
    MuxKey #(2,1,64) rs2_or_imm(
        final_b,
        is_rs2_imm,
        {
            1'b0, register_data2,
            1'b1, extended_imm
        }
    );

//***************************************************************

//--------------------------pc_sel choose--------------------------------
    //signals for compare
    wire equal;
    wire less_than;
    wire u_less_than;

    //signals for B type,is used to generate pc_sel signal
    wire beq = b_type &&(funct3 == `beq);
    wire bne = b_type &&(funct3 == `bne);
    wire blt = b_type &&(funct3 == `blt);
    wire bge = b_type &&(funct3 == `bge);
    wire bltu = b_type &&(funct3 == `bltu);
    wire bgeu = b_type &&(funct3 == `bgeu);
    always @(*) begin        //pc sel logic
        if (~sys_rst) 
            pc_sel=0;
        else if (j_type) begin
            pc_sel=1'b1;
        end 
        else if (beq && equal) begin
            pc_sel=1'b1;
        end
        else if (bne && ~equal) begin
            pc_sel=1'b1;
        end
        else if (blt && less_than) begin
            pc_sel=1'b1;
        end
        else if (bge && ~less_than) begin
            pc_sel=1'b1;
        end
        else if (bltu && u_less_than) begin
            pc_sel=1'b1;
        end
        else if (bgeu &&~u_less_than) begin
            pc_sel=1'b1;
        end
        else 
            pc_sel =1'b0;
    end
    compare u_compare(
        register_data1,
        register_data2,
        equal,
        less_than,
        u_less_than
    );
//---------------------------end------------------------------------------------

    always @(*) begin //writdata WIDTH options ,four options
        if (s_type) begin
            case (funct3)
                `sb:write_width=8'd1;
                `sh:write_width=8'd3;
                `sw:write_width=8'd15; 
                `sd:write_width=8'd127;
                default: write_width=8'd0;
            endcase
        end
        else
            write_width=8'd0;
    end

    wire wen = r_type | i_type | l_type | j_type | u_type ;     //register write enable 
    always @(*) begin
        if (l_type) 
            wb_select = 2'b01;
        else if (j_type) begin
            wb_select = 2'b10;  //pc_plus_4;
        end
        else
            wb_select = 2'b00;  //alu_res
    end
    reg [63:0]write_data;
    //************************tiny sign extender-----------------
    always @(*) begin
        if(l_type)begin
            case (funct3)
                `lb: 
                    write_data = {{57{write_back_data[7]}},write_back_data[6:0]};
                `lw: 
                    write_data = {{33{write_back_data[31]}},write_back_data[30:0]};
                `ld:
                    write_data=write_back_data;
                `lbu:
                    write_data={58'b0,write_back_data[7:0]};
                default: write_data =write_back_data;
            endcase        
        end else
            write_data =write_back_data;
    end
    //************************************************************

    always @(*) begin
        if (r_type) begin
            case (funct3)
                `add_or_sub:
                    alu_op=`alu_add;
                `sll:
                    alu_op = `alu_sl;    //sll
                `slt:
                    alu_op = `alu_add;        //this
                `sltu:
                    alu_op = `alu_add;        //this
                `xor:
                    alu_op = `alu_xor;
                `srl_and_sra:
                    if (funct7 == 7'b0) 
                        alu_op = `alu_sr; //srl
                    else
                        alu_op = `alu_sra;        //sra
                `or:
                    alu_op = `alu_or;
                `and:
                    alu_op = `alu_and;
            endcase
        end 
        else if (i_type) begin
            case (funct3)
                `addi:
                    alu_op = `alu_add;
                `slti:
                    alu_op = `alu_add;        //this
                `sltiu:
                    alu_op = `alu_add;        //this
                `xori:
                    alu_op = `alu_xor;
                `ori:
                    alu_op = `alu_or;
                `andi:
                    alu_op = `alu_and;
                `slli:
                    alu_op = `alu_sl;     //slli
                `srli_and_srai:
                    if (funct7[6:1] == 6'b0) 
                        alu_op = `alu_sr; //srli
                    else
                        alu_op = `alu_sra;        //srai
            endcase
        end
        else
            alu_op = `alu_add;            //use comparator to compare sizes!
    end

    regfile #(5,64)u_regfile(
        sys_clk,
        sys_rst,
        rs1,
        rs2,
        rd,
        write_data,
        register_data1,
        register_data2,
        wen
        // ~(b_type|s_type)        //only b type and s type not write back register
    );

/////////////////////////////imm extend//////////////////////////////

    imm_extend u_imm_extend(
        .instruction(instruction),
        .r_type(r_type),
        .i_type(i_type),
        .l_type(l_type),
        .s_type(s_type),
        .b_type(b_type),
        .j_type(j_type),
        .u_type(u_type),
        .extended_imm(extended_imm)
    );
//////////////////////////////imm extend end/////////////////////////


endmodule
