`include "para.v"
module cpu (input sys_clk,
            input sys_rst,
            output [`width]now_pc,
            output ebreak
            );
    
    
    wire pc_sel;
    wire [`width] pc_plus_4;
    // wire [`width] now_pc;
    wire [31:0] instruction;
    
    wire [`width] alu_res;
    ifu u_IFU(
    .sys_clk   (sys_clk),
    .sys_rst   (sys_rst),
    .offset_pc (alu_res),
    .pc_sel    (pc_sel),
    .now_pc    (now_pc),
    .pc_plus_4 (pc_plus_4),
    .instruction(instruction)
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

    idu u_IDU(
    .sys_clk                   (sys_clk),
    .now_pc                    (now_pc),
    .pc_plus_4                 (pc_plus_4),
    .instruction               (instruction),
    .final_a                   (final_a),
    .final_b                   (final_b),
    .is_write_dmem             (is_write_dmem),
    .wb_select                 (wb_select),
    .write_width               (write_width),
    .write_back_data           (write_back_data),
    .dmem_write_data           (rs2),
    .sub                       (sub),
    .slt_and_spin_off_signed   (slt_and_spin_off_signed),
    .slt_and_spin_off_unsigned (slt_and_spin_off_unsigned),
    .alu_op                    (alu_op),
    .pc_sel                    (pc_sel),
    .word_op                    (word_op),
    .ebreak                    (ebreak)
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
    	.sys_clk         (sys_clk         ),
        .sys_rst         (sys_rst         ),
        .wb_select       (wb_select       ),
        .pc_plus_4       (pc_plus_4       ),
        .alu_res         (alu_res         ),
        .rs2             (rs2             ),
        .write_width     (write_width     ),
        .write_enable    (write_enable    ),
        .write_back_data (write_back_data ),
        .vmem_data       (vmem_data       )
    );
    
endmodule
