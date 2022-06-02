`include "para.v"
module ysyx_22040383_idu (
    input sys_clk,
    input [31:0] instruction,
    input [`ysyx_22040383_width] now_pc,        //signal to mux that across regfile and alu's b port
    ////signals for compare
    input equal,
    input less_than,
    input u_less_than,
    output j_type,
    output s_type,
    output b_type,
    output reg is_rs1_pc,
    output is_rs2_imm,
    output [4:0] to_pipeline_rd, 
    output [`ysyx_22040383_reg_width] rs1,
    output [`ysyx_22040383_reg_width] rs2,
    ////////////////////hazard control signals ////////
    output if_idpr_invalid,
    output has_rs1,
    output has_rs2,
    ///////////////////////////////////////////////////
    //signals to MEM_EB
    output is_write_dmem,
    output is_write_rf,
    output reg [1:0] wb_select,
    output reg [7:0] write_width,
    output sub,
    output slt_and_spin_off_signed,
    output slt_and_spin_off_unsigned,
    output reg [3:0]alu_op,
    output reg pc_sel,              //pc_sel to if
    output word_op,             //signal to exu to judge caculate is word oprate
    output ebreak
);


    wire [`ysyx_22040383_width] preselect_original_operator_b;

    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

        ///this rd to id_ex register//
    assign to_pipeline_rd = instruction[11:7];
    /////////////////////////////////

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];


    //ebreak signal
    assign ebreak = ( opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);

    // wire [`ysyx_22040383_width] write_back_data;
    wire rw_type= opcode == `ysyx_22040383_rw_type_opcode;
    wire iw_type= opcode == `ysyx_22040383_iw_type_opcode;
    wire r_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]) ||(rw_type);     //0110011
    wire i_type = (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]) ||(iw_type);     //0010011
    wire l_type = (~opcode[6]&~opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);
    assign j_type = ( opcode[6]& opcode[5]&~opcode[4]& opcode[3]& opcode[2]& opcode[1]& opcode[0]) | ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //jal and jalr
    assign b_type = ( opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //1100011
    assign s_type = (~opcode[6]& opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);     //0100011
    wire u_type = (~opcode[6]& opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]) | (~opcode[6]&~opcode[5]& opcode[4]&~opcode[3]& opcode[2]& opcode[1]& opcode[0]); //
    ////////////////hazard control signals////////////////
    assign if_idpr_invalid= j_type||b_type;
    assign has_rs1 = ~((j_type && opcode == `ysyx_22040383_jal_type_opcode) || u_type);
    assign has_rs2 = r_type || b_type || s_type;
    
    ////////////////////////

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
            if(opcode == `ysyx_22040383_jal_type_opcode )
                is_rs1_pc = 1'b1;
            else is_rs1_pc=1'b0;
        end 
        else if(opcode == `ysyx_22040383_auipc_opcode)
            is_rs1_pc =1'b1;
        else if (b_type) begin
            is_rs1_pc =1'b1;
        end
        else is_rs1_pc =1'b0;
    end
    assign is_rs2_imm = i_type || u_type || j_type || l_type ||s_type ||b_type;    //final b choose,only when ins is r type, rs2 is register.
    
    

//--------------------------pc_sel choose--------------------------------


    //signals for B type,is used to generate pc_sel signal
    wire beq = b_type &&(funct3 == `ysyx_22040383_beq);
    wire bne = b_type &&(funct3 == `ysyx_22040383_bne);
    wire blt = b_type &&(funct3 == `ysyx_22040383_blt);
    wire bge = b_type &&(funct3 == `ysyx_22040383_bge);
    wire bltu = b_type &&(funct3 == `ysyx_22040383_bltu);
    wire bgeu = b_type &&(funct3 == `ysyx_22040383_bgeu);
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

    
//---------------------------end------------------------------------------------

    always @(*) begin //writdata width options ,four options
        if (s_type) begin
            case (funct3)
                `ysyx_22040383_sb:write_width=8'b00000001;
                `ysyx_22040383_sh:write_width=8'b00000011;
                `ysyx_22040383_sw:write_width=8'b00001111; 
                `ysyx_22040383_sd:write_width=8'b11111111;
                default: write_width=8'd0;
            endcase
        end
        else
            write_width=8'd0;
    end

    assign is_write_rf = r_type | i_type | l_type | j_type | u_type ;     //register write enable 
    always @(*) begin
        if (l_type) 
            wb_select = 2'b01;
        else if (j_type) begin
            wb_select = 2'b10;  //pc_plus_4;
        end
        else
            wb_select = 2'b00;  //alu_res
    end
    //************************tiny sign extender-----------------
    // reg [63:0]write_data;
    // always @(*) begin
    //     if(l_type)begin
    //         case (funct3)
    //             `ysyx_22040383_lb: 
    //                 write_data = {{57{write_back_data[7]}},write_back_data[6:0]};
    //             `ysyx_22040383_lh:
    //                 write_data = {{49{write_back_data[15]}} ,write_back_data[14:0]};
    //             `ysyx_22040383_lhu:
    //                 write_data = {48'b0,write_back_data[15:0]};
    //             `ysyx_22040383_lw: 
    //                 write_data = {{33{write_back_data[31]}},write_back_data[30:0]};
    //             `ysyx_22040383_lbu:
    //                 write_data = {56'b0,write_back_data[7:0]};
    //             `ysyx_22040383_ld:
    //                 write_data=write_back_data;
    //             default: write_data =write_back_data;
    //         endcase        
    //     end else if (word_op) begin
    //         write_data = {{33{write_back_data[31]}},write_back_data[30:0]};
    //     end else
    //         write_data =write_back_data;
    // end
    //*********************************************

    always @(*) begin
        if (r_type) begin
            case (funct3)
                `ysyx_22040383_add_or_sub_or_mul:
                begin
                    if ((r_type||rw_type)&&funct7==7'b1) begin            //when f7 is 7'b1,operator is mul!fixed bug
                        alu_op = `ysyx_22040383_alu_mul;
                    end else
                        alu_op=`ysyx_22040383_alu_add;
                end
                `ysyx_22040383_sllx:
                    alu_op = `ysyx_22040383_alu_sl;    //sll and sllw
                `ysyx_22040383_slt:
                    alu_op = `ysyx_22040383_alu_add;        //this
                `ysyx_22040383_sltu:
                    alu_op = `ysyx_22040383_alu_add;        //this
                `ysyx_22040383_xor_or_div:
                    if (rw_type) begin
                        alu_op = `ysyx_22040383_alu_div;
                    end else alu_op = `ysyx_22040383_alu_xor;
                `ysyx_22040383_srlx_and_srax:
                    if (funct7 == 7'b0) 
                        alu_op = `ysyx_22040383_alu_sr; //srl and srlw
                    else
                        alu_op = `ysyx_22040383_alu_sra;        //sra
                `ysyx_22040383_or_or_rem:
                    if (rw_type) begin
                        alu_op = `ysyx_22040383_alu_rem;
                    end else alu_op = `ysyx_22040383_alu_or;
                `ysyx_22040383_and:
                    alu_op = `ysyx_22040383_alu_and;
                
            endcase 
        end 
        else if (i_type) begin
            case (funct3)
                `ysyx_22040383_addi:
                    alu_op = `ysyx_22040383_alu_add;
                `ysyx_22040383_slti:
                    alu_op = `ysyx_22040383_alu_add;        //this
                `ysyx_22040383_sltiu:
                    alu_op = `ysyx_22040383_alu_add;        //this
                `ysyx_22040383_xori:
                    alu_op = `ysyx_22040383_alu_xor;
                `ysyx_22040383_ori:
                    alu_op = `ysyx_22040383_alu_or;
                `ysyx_22040383_andi:
                    alu_op = `ysyx_22040383_alu_and;
                `ysyx_22040383_sllx:
                    alu_op = `ysyx_22040383_alu_sl;     //slli
                `ysyx_22040383_srlx_and_srax:
                    if (funct7 == 7'b0) 
                        alu_op = `ysyx_22040383_alu_sr; //srli
                    else
                        alu_op = `ysyx_22040383_alu_sra;        //srai
            endcase
        end
        else
            alu_op = `ysyx_22040383_alu_add;            //use comparator to compare sizes!
    end






endmodule
