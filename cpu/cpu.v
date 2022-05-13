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
    
    wire [`width] if_now_pc      = now_pc;
    wire [`width] if_pc_plus_4   = pc_plus_4;
    wire [`width] if_instruction = instruction;
    
    wire [`width] id_now_pc;
    wire [`width] id_pc_plus_4;
    wire [`width] id_instruction;
    if_id u_if_id(
    .sys_clk        (sys_clk),
    .sys_rst        (sys_rst),
    .valid          (valid),
    .if_now_pc      (if_now_pc),
    .if_pc_plus_4   (if_pc_plus_4),
    .if_instruction (if_instruction),
    .id_now_pc      (id_now_pc),
    .id_pc_plus_4   (id_pc_plus_4),
    .id_instruction (id_instruction)
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
    
    wire word_op;
    
    idu u_idu(
    .sys_clk                   (sys_clk),
    .instruction               (id_instruction),
    .now_pc                    (id_now_pc),
    .pc_plus_4                 (id_pc_plus_4),
    .wb_rd                     (wb_rd),
    .to_pipeline_rd            (to_pipeline_rd),
    .final_a                   (final_a),
    .final_b                   (final_b),
    .is_write_dmem             (is_write_dmem),
    .wb_select                 (wb_select),
    .write_width               (write_width),
    .write_back_data           (write_back_data),
    .dmem_write_data           (dmem_write_data),
    .sub                       (sub),
    .slt_and_spin_off_signed   (slt_and_spin_off_signed),
    .slt_and_spin_off_unsigned (slt_and_spin_off_unsigned),
    .alu_op                    (alu_op),
    .pc_sel                    (pc_sel),
    .word_op                   (word_op),
    .ebreak                    (ebreak)
    );
    
    wire [`width] ex_final_a;      
    wire [`width] ex_final_b;      
    wire [2:0]ex_alu_op;
    wire ex_sub;
    wire ex_slt_and_spin_off_signed;
    wire ex_slt_and_spin_off_unsigned;
    wire ex_is_write_dmem;
    wire [1:0] ex_wb_select;
    wire [7:0] ex_write_width;
    wire [`width] ex_dmem_write_data;

    id_ex u_id_ex(
    	.sys_clk                      (sys_clk                      ),
        .sys_rst                      (sys_rst                      ),
        .valid                        (valid                        ),
        .id_final_a                   (final_a                   ),
        .id_final_b                   (final_b                   ),
        .id_is_write_dmem             (is_write_dmem             ),
        .id_wb_select                 (wb_select                 ),
        .id_write_width               (write_width               ),
        .id_dmem_write_data           (dmem_write_data           ),
        .id_sub                       (sub                       ),
        .id_slt_and_spin_off_signed   (slt_and_spin_off_signed   ),
        .id_slt_and_spin_off_unsigned (slt_and_spin_off_unsigned ),
        .id_alu_op                    (alu_op                    ),
        .ex_final_a                   (ex_final_a                   ),
        .ex_final_b                   (ex_final_b                   ),
        .ex_alu_op                    (ex_alu_op                    ),
        .ex_sub                       (ex_sub                       ),
        .ex_slt_and_spin_off_signed   (ex_slt_and_spin_off_signed   ),
        .ex_slt_and_spin_off_unsigned (ex_slt_and_spin_off_unsigned ),
        .ex_is_write_dmem             (ex_is_write_dmem             ),
        .ex_wb_select                 (ex_wb_select                 ),
        .ex_write_width               (ex_write_width               ),
        .ex_dmem_write_data           (ex_dmem_write_data           )
    );
    
    
    exu u_EXU(
    .a                         (final_a),
    .b                         (final_b),
    .res                       (alu_res),
    .alu_op                    (alu_op),
    .sub                       (sub),
    .slt_and_spin_off_signed   (slt_and_spin_off_signed),
    .slt_and_spin_off_unsigned (slt_and_spin_off_unsigned),
    .word_op                    (word_op)
    );
    
    mem u_mem(
    .sys_clk         (sys_clk),
    .sys_rst         (sys_rst),
    .wb_select       (wb_select),
    .pc_plus_4       (pc_plus_4),
    .alu_res         (alu_res),
    .rs2             (rs2),
    .write_width     (write_width),
    .write_enable    (write_enable),
    .write_back_data (write_back_data),
    .vmem_data       (vmem_data)
    );
    
endmodule
