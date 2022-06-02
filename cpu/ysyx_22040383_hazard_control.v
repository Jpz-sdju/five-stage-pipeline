`include "para.v"
module ysyx_22040383_hazard_control (
    input valid,
    input id_is_store,
    input has_rs1,
    input has_rs2,
    input exe_has_rd,
    input mem_has_rd,
    input wb_has_rd,
    /////////load-use control
    input [6:0] exe_instr_opcode,

    /////////flush control////////
    input ex_is_flushed,
    input mem_is_flushed,
    input wb_is_flushed,
    input [`ysyx_22040383_reg_width] id_rs1,
    input [`ysyx_22040383_reg_width] id_rs2,
    input [`ysyx_22040383_reg_width] exe_rd,
    input [`ysyx_22040383_reg_width] mem_rd,
    input [`ysyx_22040383_reg_width] wb_rd,
    output reg [1:0] forwarding_a_option,
    output reg [1:0] forwarding_b_option,
    //////flush
    output reg flush_id_reg,
    output reg flush_exe_reg,
    //////stall
    output reg stall_id_reg
);

    wire id_rs1_eq_exe_rd = (id_rs1 == exe_rd)?1'b1:1'b0;
    wire id_rs2_eq_exe_rd = (id_rs2 == exe_rd)?1'b1:1'b0;
    wire id_rs1_eq_mem_rd = (id_rs1 == mem_rd)?1'b1:1'b0;
    wire id_rs2_eq_mem_rd = (id_rs2 == mem_rd)?1'b1:1'b0;
    wire id_rs1_eq_wb_rd =  (id_rs1 == wb_rd)?1'b1:1'b0;
    wire id_rs2_eq_wb_rd =  (id_rs2 == wb_rd)?1'b1:1'b0;

    wire definite_rs1_forwarding = (id_rs1 != 5'b0)&&has_rs1&&(~ex_is_flushed&&id_rs1_eq_exe_rd&&exe_has_rd || ~mem_is_flushed && id_rs1_eq_mem_rd&&mem_has_rd || ~wb_is_flushed && id_rs1_eq_wb_rd && wb_has_rd); 
    wire definite_rs2_forwarding = (id_rs2 != 5'b0)&&has_rs2&&(~ex_is_flushed&&id_rs2_eq_exe_rd&&exe_has_rd || ~mem_is_flushed && id_rs2_eq_mem_rd&&mem_has_rd || ~wb_is_flushed && id_rs2_eq_wb_rd && wb_has_rd);

    always @(*) begin
        if (definite_rs1_forwarding) begin
            if (~ex_is_flushed && id_rs1_eq_exe_rd && exe_has_rd) 
                forwarding_a_option = 2'b01;
            else if (~mem_is_flushed && id_rs1_eq_mem_rd && mem_has_rd ) 
                forwarding_a_option = 2'b10;
            else
                forwarding_a_option = 2'b11;
        end
        else
            forwarding_a_option=2'b00;
    end

    always @(*) begin
        if (definite_rs2_forwarding) begin
            if (id_rs2_eq_exe_rd) 
                forwarding_b_option = 2'b01;
            else if (id_rs2_eq_mem_rd) 
                forwarding_b_option = 2'b10;
            else
                forwarding_b_option = 2'b11;
        end
        else
            forwarding_b_option=2'b00;
    end

    ///////////loda-use hazard solution//////////
    wire exe_is_l_type = (~exe_instr_opcode[6]&~exe_instr_opcode[5]&~exe_instr_opcode[4]&~exe_instr_opcode[3]&~exe_instr_opcode[2]& exe_instr_opcode[1]& exe_instr_opcode[0]);

    always @(*) begin
        if (exe_is_l_type && (id_rs1_eq_exe_rd &&has_rs1 || id_rs2_eq_exe_rd && has_rs2)) begin
            flush_exe_reg=1;
            stall_id_reg=1;
        end
        else begin
            flush_exe_reg=0;
            stall_id_reg=0;
        end
    end
endmodule