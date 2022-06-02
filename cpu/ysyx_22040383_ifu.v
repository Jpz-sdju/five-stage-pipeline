`include "para.v"
module ysyx_22040383_ifu (
    input sys_clk,
    input sys_rst,
    input stall_id_reg,
    input [`ysyx_22040383_width] offset_pc,
    input pc_sel,
    output [`ysyx_22040383_width] now_pc,
    output reg [`ysyx_22040383_width] pc_plus_4,
    output reg [31:0] instruction
    // output [`ysyx_22040383_width] next_pc           //this signal is set for difftest
);
    wire [`ysyx_22040383_width] next_pc;
    MuxKey #(2,1,64) plus_4_or_more(
        next_pc,
        pc_sel,
        {
            1'b0, pc_plus_4,
            1'b1, offset_pc
        }
    );

    ysyx_22040383_pc pc_instance(sys_clk,sys_rst,next_pc,now_pc);
    // ysyx_22040383_pc_adder pc_adder_instance(sys_clk,sys_rst,now_pc,pc_plus_4);
    always @(*) begin
        if(~stall_id_reg)begin
            pc_plus_4 = now_pc+4;
        end
        else
            pc_plus_4 = now_pc;
    end

wire [`ysyx_22040383_width] dpic_data;
// assign instruction = ((next_pc- 64'h80000000)/4)%2 == 1?dpic_data[63:32]:dpic_data[31:0];
// assign instruction = dpic_data[31:0];

//------------------------------------dpi-c-------------------------
import "DPI-C" function void pmem_read(
        input longint raddr, output longint rdata);
    always @(posedge sys_clk) begin
        if (~stall_id_reg) begin
            pmem_read(next_pc, dpic_data);
            instruction <=((next_pc- 64'h80000000)/4)%2 == 1?dpic_data[63:32]:dpic_data[31:0];
        end
    end
//--------------------------------------------------------------------------------



endmodule