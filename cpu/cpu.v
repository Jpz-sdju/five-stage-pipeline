`include "para.v"
module cpu (input sys_clk,
            input sys_rst,
            output [`width]now_pc,
            output ebreak);
    
    
    wire pc_sel;
    wire [`width] pc_plus_4;
    // wire [`width] now_pc;
    wire [31:0] instruction;
    
    wire [`width] alu_res;
    
    wire valid;
    
    ifu u_IFU(
    .sys_clk   (sys_clk),
    .sys_rst   (sys_rst),
    .offset_pc (alu_res),
    .pc_sel    (pc_sel),
    .now_pc    (now_pc),
    .pc_plus_4 (pc_plus_4),
    .instruction(instruction)
    );
    
    wire [`width] if_idpr_now_pc      = now_pc;
    wire [`width] if_idpr_pc_plus_4   = pc_plus_4;
    wire [`width] if_idpr_instruction = instruction;
    
    wire [`width] idpr_id_now_pc;
    wire [`width] idpr_id_pc_plus_4;
    wire [`width] idpr_id_instruction;
    if_id u_if_id(
    .sys_clk             (sys_clk),
    .sys_rst             (sys_rst),
    .valid               (valid),
    .if_idpr_now_pc      (if_idpr_now_pc),
    .if_idpr_pc_plus_4   (if_idpr_pc_plus_4),
    .if_idpr_instruction (if_idpr_instruction),
    .idpr_id_now_pc      (idpr_id_now_pc),
    .idpr_id_pc_plus_4   (idpr_id_pc_plus_4),
    .idpr_id_instruction (idpr_id_instruction)
    );
    
    
    
    wire [`width] final_a;
    wire [`width] final_b;
    wire is_write_dmem;
    wire [1:0] wb_select;
    wire [7:0] write_width;
    wire [`width] write_back_data;
    wire sub;
    wire slt_and_spin_off_signed;
    wire slt_and_spin_off_unsigned;
    wire [3:0] alu_op;
    wire [`width] rs2;
    
    
    wire [`width] id_expr_final_a;
    wire [`width] id_expr_final_b;
    //signals to MEM_EB
    wire id_expr_is_write_dmem;
    wire [1:0] id_expr_wb_select;
    wire [7:0] id_expr_write_width;
    wire [`width] id_expr_dmem_write_data;
    wire id_expr_sub;
    wire id_expr_slt_and_spin_off_signed;
    wire id_expr_slt_and_spin_off_unsigned;
    wire [2:0]id_expr_alu_op;
    wire id_expr_word_op;
    wire id_expr_pc_sel;
    wire [4:0] id_expr_rd;
    
    idu u_idu(
    .sys_clk                   (sys_clk),
    .instruction               (idpr_id_instruction),
    .now_pc                    (idpr_id_now_pc),
    .wb_rd                     (wb_rd),
    ////////////////output///////////////
    .to_pipeline_rd            (id_expr_rd),
    .final_a                   (id_expr_final_a),
    .final_b                   (id_expr_final_b),
    .is_write_dmem             (id_expr_is_write_dmem),
    .wb_select                 (id_expr_wb_select),
    .write_width               (id_expr_write_width),
    .write_back_data           (id_expr_write_back_data),
    .dmem_write_data           (id_expr_dmem_write_data),
    .sub                       (id_expr_sub),
    .slt_and_spin_off_signed   (id_expr_slt_and_spin_off_signed),
    .slt_and_spin_off_unsigned (id_expr_slt_and_spin_off_unsigned),
    .alu_op                    (id_expr_alu_op),
    .pc_sel                    (id_expr_pc_sel),
    .word_op                   (id_expr_word_op),
    .ebreak                    (ebreak)
    );
    
    
    wire [`width] expr_ex_final_a;
    wire [`width] expr_ex_final_b;
    wire [2:0]expr_ex_alu_op;
    wire expr_ex_sub;
    wire expr_ex_slt_and_spin_off_signed;
    wire expr_ex_slt_and_spin_off_unsigned;
    wire expr_ex_is_write_dmem;
    wire [1:0] expr_ex_wb_select;
    wire [7:0] expr_ex_write_width;
    wire [`width] expr_ex_dmem_write_data;
    wire expr_ex_word_op;
    wire expr_ex_pc_sel;
    
    id_ex u_id_ex(
    	.sys_clk                           (sys_clk                           ),
        .sys_rst                           (sys_rst                           ),
        .valid                             (valid                             ),
        .id_expr_final_a                   (id_expr_final_a                   ),
        .id_expr_final_b                   (id_expr_final_b                   ),
        .id_expr_pc_plus_4                 (id_expr_pc_plus_4                 ),
        .id_expr_is_write_dmem             (id_expr_is_write_dmem             ),
        .id_expr_rd                        (id_expr_rd                        ),
        .id_expr_wb_select                 (id_expr_wb_select                 ),
        .id_expr_write_width               (id_expr_write_width               ),
        .id_expr_dmem_write_data           (id_expr_dmem_write_data           ),
        .id_expr_sub                       (id_expr_sub                       ),
        .id_expr_slt_and_spin_off_signed   (id_expr_slt_and_spin_off_signed   ),
        .id_expr_slt_and_spin_off_unsigned (id_expr_slt_and_spin_off_unsigned ),
        .id_expr_alu_op                    (id_expr_alu_op                    ),
        .id_expr_word_op                   (id_expr_word_op                   ),
        .id_expr_pc_sel                    (id_expr_pc_sel                    ),
        .expr_ex_final_a                   (expr_ex_final_a                   ),
        .expr_ex_final_b                   (expr_ex_final_b                   ),
        .expr_ex_pc_plus_4                 (expr_ex_pc_plus_4                 ),
        .expr_ex_alu_op                    (expr_ex_alu_op                    ),
        .expr_ex_sub                       (expr_ex_sub                       ),
        .expr_ex_slt_and_spin_off_signed   (expr_ex_slt_and_spin_off_signed   ),
        .expr_ex_slt_and_spin_off_unsigned (expr_ex_slt_and_spin_off_unsigned ),
        .expr_ex_word_op                   (expr_ex_word_op                   ),
        .expr_ex_is_write_dmem             (expr_ex_is_write_dmem             ),
        .expr_ex_wb_select                 (expr_ex_wb_select                 ),
        .expr_ex_write_width               (expr_ex_write_width               ),
        .expr_ex_dmem_write_data           (expr_ex_dmem_write_data           ),
        .expr_ex_rd                        (expr_ex_rd                        ),
        .expr_ex_pc_sel                    (expr_ex_pc_sel                    )
    );
    
    
    wire [`width] ex_mempr_alu_res;
    wire ex_mempr_is_write_dmem=expr_ex_is_write_dmem;
    wire [1:0]ex_mempr_wb_select=expr_ex_wb_select;
    wire [7:0] ex_mempr_write_width=expr_ex_write_width;
    wire [`width] ex_mempr_dmem_write_data=expr_ex_dmem_write_data;

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
    
    wire mempr_mem_is_write_dmem;
    wire [1:0]mempr_mem_wb_select;
    wire [7:0] mempr_mem_write_width;
    wire [`width] mempr_mem_dmem_write_data;
    wire [`width] mempr_mem_alu_res;

ex_mem u_ex_mem(
    .sys_clk                   (sys_clk                   ),
    .sys_rst                   (sys_rst                   ),
    .valid                     (valid                     ),
    .ex_mempr_is_write_dmem    (ex_mempr_is_write_dmem    ),
    .ex_mempr_wb_select        (ex_mempr_wb_select        ),
    .ex_mempr_write_width      (ex_mempr_write_width      ),
    .ex_mempr_dmem_write_data  (ex_mempr_dmem_write_data  ),
    .ex_mempr_alu_res          (ex_mempr_alu_res          ),
    .mempr_mem_is_write_dmem   (mempr_mem_is_write_dmem   ),
    .mempr_mem_wb_select       (mempr_mem_wb_select       ),
    .mempr_mem_write_width     (mempr_mem_write_width     ),
    .mempr_mem_dmem_write_data (mempr_mem_dmem_write_data ),
    .mempr_mem_alu_res         (mempr_mem_alu_res         )
);

    
    
    
    mem u_mem(
    .sys_clk         (sys_clk),
    .sys_rst         (sys_rst),
    .wb_select       (mempr_mem_wb_select),
    .pc_plus_4       (mempr_mem_pc_plus_4),
    .alu_res         (mempr_mem_alu_res),
    .rs2             (rs2),
    .write_width     (write_width),
    .write_enable    (write_enable),
    .write_back_data (mem_write_back_data),
    .vmem_data       (vmem_data)
    );
    
    mem_wb u_mem_wb(
    .sys_clk                  (sys_clk),
    .sys_rst                  (sys_rst),
    .valid                    (valid),
    .mem_wbpr_write_back_addr (mem_wbpr_write_back_addr),
    .mem_wbpr_write_back_data (mem_wbpr_write_back_data),
    .wbpr_wb_write_back_addr  (wbpr_wb_write_back_addr),
    .wbpr_wb_write_back_data  (wbpr_wb_write_back_data)
    );
    
    wb u_wb(
    .fake_write_back_data (fake_write_back_data),
    .fake_write_back_addr (fake_write_back_addr),
    .real_write_back_data (real_write_back_data),
    .real_write_back_addr (real_write_back_addr)
    );
    
endmodule
