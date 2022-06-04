`include "para.v"
module cpu (input sys_clk,
            input sys_rst,
            output [63:0]vmem_reg
            // output [`width]now_pc,
            // output stall,
            // output ebreak
            );
    ////////difftest signals//////////////
    
    wire wbpr_wb_stall;
    // assign stall = wbpr_wb_stall;
    
    
    ///////end of difftest signals//////////
    wire [`width] offset_pc;
    wire [`width] hazard_control_offset_pc;
    wire pc_sel;
    //////////////////////////////////////////////////////////
    wire [`width] if_idpr_now_pc ;
    wire [`width] if_idpr_pc_plus_4;
    wire [31:0]   if_idpr_instruction ;
    wire stall_id_reg;
    ifu u_IFU(
    .sys_clk   (sys_clk),
    .sys_rst   (sys_rst),
    .offset_pc (offset_pc),
    .stall_id_reg(stall_id_reg),
    .pc_sel    (pc_sel&&~stall_id_reg),
    .now_pc    (if_idpr_now_pc),
    .pc_plus_4 (if_idpr_pc_plus_4),
    .instruction(if_idpr_instruction)
    
    );
    wire j_type;
    wire s_type;
    wire b_type;
    wire valid;
    
    
    wire [`width] idpr_id_now_pc;
    wire [`width] idpr_id_pc_plus_4;
    wire [31:0] idpr_id_instruction;
    wire [`width] idpr_expr_next_pc;
    
    if_id u_if_id(
    .sys_clk             (sys_clk),
    .sys_rst             (sys_rst),
    .invalid             (pc_sel),
    .stall_id_reg        (stall_id_reg),
    .if_idpr_now_pc      (if_idpr_now_pc),
    .if_idpr_pc_plus_4   (if_idpr_pc_plus_4),
    .if_idpr_instruction (if_idpr_instruction),
    .idpr_id_now_pc      (idpr_id_now_pc),
    .idpr_id_pc_plus_4   (idpr_id_pc_plus_4),
    .idpr_id_instruction (idpr_id_instruction)
    );
    
    
    wire [`width] id_expr_pc_plus_4 = idpr_id_pc_plus_4;
    //signals to MEM_EB
    wire id_expr_is_write_dmem;
    wire id_expr_is_write_rf;
    wire [1:0] id_expr_wb_select;
    wire [7:0] id_expr_write_width;
    
    wire id_expr_sub;
    wire id_expr_slt_and_spin_off_signed;
    wire id_expr_slt_and_spin_off_unsigned;
    wire [3:0]id_expr_alu_op;
    wire id_expr_word_op;
    reg id_expr_stall;
    wire flush_id_reg;
    always @(posedge sys_clk) begin
        if (flush_id_reg) begin
            id_expr_stall <= 1;
        end
        else if (stall_id_reg) begin
            id_expr_stall <= 0;
        end
        else
            id_expr_stall <= pc_sel;
    end
    // wire id_expr_stall = pc_sel;
    wire [4:0] id_expr_rd;
    
    ///////write back/////////
    wire [4:0] wb_addr;
    wire [`width] wb_data;
    ////////////hazard.///////////////
    wire [`reg_width] rs1;
    wire [`reg_width] rs2;
    wire [`width] original_operator_a;
    wire [`width] original_operator_b;
    wire if_idpr_invalid;
    wire has_rs1;
    wire has_rs2;
    wire is_rs1_pc;
    wire is_rs2_imm;
    wire exe_has_rd;
    wire mem_has_rd;
    wire wb_has_rd;
    
    
    wire equal;
    wire less_than;
    wire u_less_than;
    //////////////////////////////////
    idu u_idu(
    .sys_clk                   (sys_clk),
    .instruction               (idpr_id_instruction),
    .now_pc                    (idpr_id_now_pc),
    .j_type                    (j_type),
    .s_type                    (s_type),
    .b_type                    (b_type),
    .is_rs1_pc                 (is_rs1_pc),
    .is_rs2_imm                (is_rs2_imm),
    .has_rs1                   (has_rs1),
    .has_rs2                   (has_rs2),
    .equal                     (equal),
    .less_than                 (less_than),
    .u_less_than               (u_less_than),
    ////////////////output///////////////
    .to_pipeline_rd            (id_expr_rd),
    .rs1                       (rs1),
    .rs2                       (rs2),
    .if_idpr_invalid           (if_idpr_invalid),
    .is_write_dmem             (id_expr_is_write_dmem),
    .is_write_rf               (id_expr_is_write_rf),
    .wb_select                 (id_expr_wb_select),
    .write_width               (id_expr_write_width),
    .sub                       (id_expr_sub),
    .slt_and_spin_off_signed   (id_expr_slt_and_spin_off_signed),
    .slt_and_spin_off_unsigned (id_expr_slt_and_spin_off_unsigned),
    .alu_op                    (id_expr_alu_op),
    .pc_sel                    (pc_sel),  //!this signal is updated!!!
    .word_op                   (id_expr_word_op),
    .ebreak                    (ebreak)
    );
    wire [`width] register_data1;
    wire [`width] register_data2;
    wire [`width] updated_rs1;
    wire [`width] updated_rs2;
    wire real_is_write_rf;
    regfile #(32,64)u_regfile(
    sys_clk,
    sys_rst,
    rs1,
    rs2,
    wb_addr,
    wb_data,
    register_data1,
    register_data2,
    real_is_write_rf
    // ~(b_type|s_type)        //only b type and s type not write back register
    );
    wire [1:0] forwarding_a_option;
    wire [1:0] forwarding_b_option;
    wire [`width] id_expr_rs2_data = register_data2;
    
    
    wire flush_exe_reg;
    
    
    wire [`instr_width] wbpr_wb_instruction;
    wire expr_mempr_is_write_rf;
    wire [4:0] expr_mempr_rd;
    wire [`instr_width] expr_mempr_instruction;
    wire mempr_wbpr_is_write_rf;
    wire [4:0] mempr_wbpr_rd;
    wire [`instr_width] mempr_wbpr_instruction;
    
    hazard_control u_control(
    .valid               (valid),
    .id_is_store         (s_type),
    .has_rs1             (has_rs1),
    .has_rs2             (has_rs2),
    .exe_has_rd          (expr_mempr_is_write_rf),
    .mem_has_rd          (mempr_wbpr_is_write_rf),
    .wb_has_rd           (real_is_write_rf),
    .exe_instr_opcode    (expr_mempr_instruction[6:0]),
    .ex_is_flushed       (expr_mempr_instruction == 32'b0),
    .mem_is_flushed      (mempr_wbpr_instruction == 32'b0),
    .wb_is_flushed       (wbpr_wb_instruction == 32'b0),
    .id_rs1              (rs1),
    .id_rs2              (rs2),
    .exe_rd              (expr_mempr_rd),
    .mem_rd              (mempr_wbpr_rd),
    .wb_rd               (wb_addr),
    .forwarding_a_option (forwarding_a_option),
    .forwarding_b_option (forwarding_b_option),
    .flush_id_reg        (flush_id_reg),
    .flush_exe_reg       (flush_exe_reg),
    .stall_id_reg        (stall_id_reg)
    );
    
    wire [`width] ex_forwarding_res;
    
    wire [`width] mem_wbpr_write_back_data;
    MuxKey #(4,2,64) final_a_mux(
    updated_rs1,
    forwarding_a_option,
    {
    2'b00, register_data1,
    2'b01, ex_forwarding_res,
    2'b10, mem_wbpr_write_back_data,
    2'b11, wb_data
    }
    );
    MuxKey #(4,2,64) final_b_mux(
    updated_rs2,
    forwarding_b_option,
    {
    2'b00, register_data2,
    2'b01, ex_forwarding_res,
    2'b10, mem_wbpr_write_back_data,
    2'b11, wb_data
    }
    );
    wire [`width] extended_imm;
    wire [`width] preselect_original_operator_b;
    imm_extend u_imm_extend(
    .instruction(idpr_id_instruction),
    .extended_imm(extended_imm)
    );
    
    MuxKey #(2,1,64) rs1_or_pc(
    original_operator_a,
    is_rs1_pc,
    {
    1'b0, updated_rs1,
    1'b1, idpr_id_now_pc
    }
    );
    MuxKey #(2,1,64) rs2_or_imm(
    preselect_original_operator_b,
    is_rs2_imm,
    {
    1'b0, updated_rs2,
    1'b1, extended_imm
    }
    );
    MuxKey #(2,1,64) ori_b_or_4(
    original_operator_b,
    j_type,
    {
    1'b0, preselect_original_operator_b,
    1'b1, 64'd4
    }
    );
    
    
    compare u_compare(
    updated_rs1,
    updated_rs2,
    equal,
    less_than,
    u_less_than
    );
    
    
    wire [`width] expr_ex_final_a;
    wire [`width] expr_ex_final_b;
    wire [`width] expr_ex_pc_plus_4;
    wire [3:0]expr_ex_alu_op;
    wire expr_ex_sub;
    wire expr_ex_slt_and_spin_off_signed;
    wire expr_ex_slt_and_spin_off_unsigned;
    wire expr_ex_is_write_dmem;
    
    wire [1:0] expr_ex_wb_select;
    wire [7:0] expr_ex_write_width;
    wire [`width] expr_ex_rs2_data;
    wire expr_ex_word_op;
    wire expr_mempr_stall;
    
    wire [`width] expr_mempr_now_pc;
    
    assign offset_pc = original_operator_a + preselect_original_operator_b; //complex design
    id_ex u_id_ex(
    .sys_clk                           (sys_clk),
    .sys_rst                           (sys_rst),
    .invalid                           (flush_exe_reg),
    .id_expr_final_a                   (original_operator_a),
    .id_expr_final_b                   (original_operator_b),
    .id_expr_pc_plus_4                 (id_expr_pc_plus_4),
    .idpr_expr_now_pc                  (idpr_id_now_pc),
    .idpr_expr_instruction             (idpr_id_instruction),
    .id_expr_is_write_dmem             (id_expr_is_write_dmem),
    .id_expr_is_write_rf               (id_expr_is_write_rf),
    .id_expr_rd                        (id_expr_rd),
    .id_expr_wb_select                 (id_expr_wb_select),
    .id_expr_write_width               (id_expr_write_width),
    .id_expr_rs2_data                  (updated_rs2),
    .id_expr_sub                       (id_expr_sub),
    .id_expr_slt_and_spin_off_signed   (id_expr_slt_and_spin_off_signed),
    .id_expr_slt_and_spin_off_unsigned (id_expr_slt_and_spin_off_unsigned),
    .id_expr_alu_op                    (id_expr_alu_op),
    .id_expr_word_op                   (id_expr_word_op),
    .id_expr_stall                     (id_expr_stall),
    .expr_ex_final_a                   (expr_ex_final_a),
    .expr_ex_final_b                   (expr_ex_final_b),
    .expr_ex_pc_plus_4                 (expr_ex_pc_plus_4),
    .expr_mempr_instruction            (expr_mempr_instruction),
    .expr_ex_alu_op                    (expr_ex_alu_op),
    .expr_ex_sub                       (expr_ex_sub),
    .expr_ex_slt_and_spin_off_signed   (expr_ex_slt_and_spin_off_signed),
    .expr_ex_slt_and_spin_off_unsigned (expr_ex_slt_and_spin_off_unsigned),
    .expr_ex_word_op                   (expr_ex_word_op),
    .expr_ex_is_write_dmem             (expr_ex_is_write_dmem),
    .expr_mempr_is_write_rf            (expr_mempr_is_write_rf),
    .expr_ex_wb_select                 (expr_ex_wb_select),
    .expr_ex_write_width               (expr_ex_write_width),
    .expr_ex_rs2_data                  (expr_ex_rs2_data),
    .expr_mempr_rd                     (expr_mempr_rd),
    .expr_mempr_stall                  (expr_mempr_stall),
    .expr_mempr_now_pc                 (expr_mempr_now_pc)
    );
    
    
    
    wire expr_mempr_is_write_dmem     = expr_ex_is_write_dmem;
    wire [1:0]expr_mempr_wb_select    = expr_ex_wb_select;
    wire [7:0] expr_mempr_write_width = expr_ex_write_width;
    wire [`width] ex_mempr_rs2_data   = expr_ex_rs2_data;
    wire [`width] ex_mempr_alu_res;
    wire [`width] ex_mempr_pc_plus_4 = expr_ex_pc_plus_4;
    
    exu u_EXU(
    .a                         (expr_ex_final_a),
    .b                         (expr_ex_final_b),
    .alu_op                    (expr_ex_alu_op),
    .sub                       (expr_ex_sub),
    .slt_and_spin_off_signed   (expr_ex_slt_and_spin_off_signed),
    .slt_and_spin_off_unsigned (expr_ex_slt_and_spin_off_unsigned),
    .word_op                   (expr_ex_word_op),
    .res                       (ex_mempr_alu_res)
    );
    
    
    write_back_extender u_exe_extender(
    .instruction    (expr_mempr_instruction),
    .unprocess_data (ex_mempr_alu_res),
    .res_data       (ex_forwarding_res)
    );
    
    wire mempr_mem_is_write_dmem;
    wire [1:0]mempr_mem_wb_select;
    wire [7:0] mempr_mem_write_width;
    wire [`width] mempr_mem_rs2_data;
    wire [`width] mempr_mem_alu_res;
    wire [`width] mempr_mem_pc_plus_4;
    wire [`width] mempr_wbpr_now_pc;
    wire mempr_wbpr_stall;
    
    ex_mem u_ex_mem(
    .sys_clk                  (sys_clk),
    .sys_rst                  (sys_rst),
    .valid                    (valid),
    .expr_mempr_is_write_dmem (expr_mempr_is_write_dmem),
    .expr_mempr_is_write_rf   (expr_mempr_is_write_rf),
    .expr_mempr_wb_select     (expr_mempr_wb_select),
    .expr_mempr_write_width   (expr_mempr_write_width),
    .ex_mempr_rs2_data        (ex_mempr_rs2_data),
    .ex_mempr_alu_res         (ex_mempr_alu_res),
    .expr_mempr_rd            (expr_mempr_rd),
    .ex_mempr_pc_plus_4       (ex_mempr_pc_plus_4),
    .expr_mempr_now_pc        (expr_mempr_now_pc),
    .expr_mempr_instruction   (expr_mempr_instruction),
    .expr_mempr_stall         (expr_mempr_stall),
    .mempr_mem_is_write_dmem  (mempr_mem_is_write_dmem),
    .mempr_wbpr_is_write_rf   (mempr_wbpr_is_write_rf),
    .mempr_mem_wb_select      (mempr_mem_wb_select),
    .mempr_mem_write_width    (mempr_mem_write_width),
    .mempr_mem_rs2_data       (mempr_mem_rs2_data),
    .mempr_mem_alu_res        (mempr_mem_alu_res),
    .mempr_wbpr_rd            (mempr_wbpr_rd),
    .mempr_mem_pc_plus_4      (mempr_mem_pc_plus_4),
    .mempr_wbpr_now_pc        (mempr_wbpr_now_pc),
    .mempr_wbpr_instruction   (mempr_wbpr_instruction),
    .mempr_wbpr_stall         (mempr_wbpr_stall)
    );
    
    
    
    
    wire [`width] mem_unprocess_data;
    mem u_mem(
    .sys_clk         (sys_clk),
    .sys_rst         (sys_rst),
    .op_sb           (expr_mempr_instruction[6:0] == `s_type_opcode && expr_mempr_instruction[14:12] == 3'b000),
    .op_sh           (expr_mempr_instruction[6:0] == `s_type_opcode && expr_mempr_instruction[14:12] == 3'b001),
    .op_sw           (expr_mempr_instruction[6:0] == `s_type_opcode && expr_mempr_instruction[14:12] == 3'b010),
    .wb_select       (mempr_mem_wb_select),
    .pc_plus_4       (mempr_mem_pc_plus_4),
    .read_addr       (ex_mempr_alu_res),//note: memory access should be taken in exe stage!
    .alu_res         (mempr_mem_alu_res),
    .rs2_data        (ex_mempr_rs2_data),   //note
    .write_width     (expr_mempr_write_width),  //note
    .write_enable    (expr_mempr_is_write_dmem),    //note
    .unprocess_data  (mem_unprocess_data),
    .vmem_reg        (vmem_reg)
    );
    write_back_extender u_mem_extender(
    .instruction    (mempr_wbpr_instruction),
    .unprocess_data (mem_unprocess_data),
    .res_data       (mem_wbpr_write_back_data)
    );
    
    
    wire [4:0] wbpr_wb_write_back_addr;
    wire [`width] wbpr_wb_write_back_data;
    wire [`width] wbpr_wb_now_pc;
    wire wbpr_wb_is_write_rf;
    mem_wb u_mem_wb(
    .sys_clk                  (sys_clk),
    .valid                    (valid),
    .mem_wbpr_write_back_data (mem_wbpr_write_back_data),
    .mem_wbpr_write_back_addr (mempr_wbpr_rd),
    .mempr_wbpr_now_pc        (mempr_wbpr_now_pc),
    .mempr_wbpr_stall         (mempr_wbpr_stall),
    .mempr_wbpr_is_write_rf   (mempr_wbpr_is_write_rf),
    .mempr_wbpr_instruction   (mempr_wbpr_instruction),
    .wbpr_wb_write_back_data  (wbpr_wb_write_back_data),
    .wbpr_wb_write_back_addr  (wbpr_wb_write_back_addr),
    .wbpr_wb_now_pc           (wbpr_wb_now_pc),
    .wbpr_wb_instruction      (wbpr_wb_instruction),
    .wbpr_wb_stall            (wbpr_wb_stall),
    .wbpr_wb_is_write_rf      (wbpr_wb_is_write_rf)
    );
    
    
    wb u_wb(
    .fake_write_back_data (wbpr_wb_write_back_data),
    .fake_write_back_addr (wbpr_wb_write_back_addr),
    .fake_is_write_rf     (wbpr_wb_is_write_rf),
    //////output/////////////
    .real_write_back_data (wb_data),
    .real_write_back_addr (wb_addr),
    .real_is_write_rf     (real_is_write_rf)
    );
    
    assign now_pc = wbpr_wb_now_pc;
endmodule
