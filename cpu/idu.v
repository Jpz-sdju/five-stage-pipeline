`include "para.v"
module idu (
    input sys_clk,
    input [31:0] instruction,
    input [`width] now_pc,        //signal to mux that across regfile and alu's b port
    input [4:0] wb_rd,
    input [`width] write_back_data,
    output [4:0] to_pipeline_rd,
    output [`width] final_a,      //oprend a to alu
    output [`width] final_b,      //oprend b to alu
    //signals to MEM_EB
    output is_write_dmem,
    output reg [1:0] wb_select,
    output reg [7:0] write_width,

    output [`width] rs2_data,
    output sub,
    output slt_and_spin_off_signed,
    output slt_and_spin_off_unsigned,
    output reg [3:0]alu_op,
    output reg pc_sel,              //pc_sel to if
    output word_op,             //signal to exu to judge caculate is word oprate
    output ebreak
);




    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    // reg [4:0] rd;
    // always @(posedge sys_clk) begin
    //     rd <= instruction [11:7];
    // end

    ///this rd to id_ex register//
    assign to_pipeline_rd = instruction[11:7];
    /////////////////////////////////

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    reg is_rs1_pc;
    wire is_rs2_imm;
    //mux data 
    wire [`width] register_data1;
    wire [`width] register_data2;
    wire [`width] extended_imm;

    assign rs2_data = register_data2;
    //ebreak signal
    assign ebreak = ( opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);

    // wire [`width] write_back_data;
    wire rw_type= opcode == `rw_type_opcode;
    wire iw_type= opcode == `iw_type_opcode;
    wire r_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]) ||(rw_type);     //0110011
    wire i_type = (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]) ||(iw_type);     //0010011
    wire l_type = (~opcode[6]&~opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);
    wire j_type = ( opcode[6]& opcode[5]&~opcode[4]& opcode[3]& opcode[2]& opcode[1]& opcode[0]) | ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //jal and jalr
    wire b_type = ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //1100011
    wire s_type = (~opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //0100011
    wire u_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]) | (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //

    /////////////////word operate////////////
    assign word_op = rw_type||iw_type;
    /////////////////word operate////////////

    assign is_write_dmem = s_type;      //only in s type,dmem should be wrote.


    //sinnals for alu to optimize 
    assign sub = (r_type && funct3 == 3'b000 && funct7 == 7'b0100000);
    assign slt_and_spin_off_signed = (r_type || i_type) && (funct3 == 3'b010 );
    assign slt_and_spin_off_unsigned = (r_type || i_type)&&(funct3 == 3'b011);

//*********************final a and final b choose******************
    always @(*) begin           //final a choose
        if(j_type)begin
            if(opcode == `jal_type_opcode )
                is_rs1_pc = 1'b1;
            else is_rs1_pc=1'b0;
        end 
        else if(opcode == `auipc_opcode)
            is_rs1_pc =1'b1;
        else if (b_type) begin
            is_rs1_pc =1'b1;
        end
        else is_rs1_pc =1'b0;
    end
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
    wire beq = b_type &&(funct3 == beq);
    wire bne = b_type &&(funct3 == bne);
    wire blt = b_type &&(funct3 == blt);
    wire bge = b_type &&(funct3 == bge);
    wire bltu = b_type &&(funct3 == bltu);
    wire bgeu = b_type &&(funct3 == bgeu);
    always @(*) begin        //pc sel logic
        if (j_type) begin
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

    always @(*) begin //writdata `width options ,four options
        if (s_type) begin
            case (funct3)
                `sb:write_width=8'b00000001;
                `sh:write_width=8'b00000011;
                `sw:write_width=8'b00001111; 
                `sd:write_width=8'b11111111;
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
                `lh:
                    write_data = {{49{write_back_data[15]}} ,write_back_data[14:0]};
                `lhu:
                    write_data = {48'b0,write_back_data[15:0]};
                `lw: 
                    write_data = {{33{write_back_data[31]}},write_back_data[30:0]};
                `lbu:
                    write_data = {56'b0,write_back_data[7:0]};
                `ld:
                    write_data=write_back_data;
                default: write_data =write_back_data;
            endcase        
        end else if (word_op) begin
            write_data = {{33{write_back_data[31]}},write_back_data[30:0]};
        end else
            write_data =write_back_data;
    end
    //*********************************************

    always @(*) begin
        if (r_type) begin
            case (funct3)
                `add_or_sub_or_mul:
                begin
                    if ((r_type||rw_type)&&funct7==7'b1) begin            //when f7 is 7'b1,operator is mul!fixed bug
                        alu_op = `alu_mul;
                    end else
                        alu_op=`alu_add;
                end
                `sllx:
                    alu_op = `alu_sl;    //sll and sllw
                `slt:
                    alu_op = `alu_add;        //this
                `sltu:
                    alu_op = `alu_add;        //this
                `xor_or_div:
                    if (rw_type) begin
                        alu_op = `alu_div;
                    end else alu_op = `alu_xor;
                `srlx_and_srax:
                    if (funct7 == 7'b0) 
                        alu_op = `alu_sr; //srl and srlw
                    else
                        alu_op = `alu_sra;        //sra
                `or_or_rem:
                    if (rw_type) begin
                        alu_op = `alu_rem;
                    end else alu_op = `alu_or;
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
                `sllx:
                    alu_op = `alu_sl;     //slli
                `srlx_and_srax:
                    if (funct7 == 7'b0) 
                        alu_op = `alu_sr; //srli
                    else
                        alu_op = `alu_sra;        //srai
            endcase
        end
        else
            alu_op = `alu_add;            //use comparator to compare sizes!
    end

    regfile #(32,64)u_regfile(
        sys_clk,
        rs1,
        rs2,
        wb_rd,
        write_data,
        register_data1,
        register_data2,
        wen
        // ~(b_type|s_type)        //only b type and s type not write back register
    );



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



endmodule
