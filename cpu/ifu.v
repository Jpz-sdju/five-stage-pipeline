`include "para.v"
module ifu (
    input sys_clk,
    input sys_rst,
    input stall_id_reg,
    input [`width] offset_pc,
    input pc_sel,
    output [`width] now_pc,
    output reg [`width] pc_plus_4,
    output [31:0] instruction
    // output [`width] next_pc           //this signal is set for difftest
);
    wire [`width] next_pc;
    MuxKey #(2,1,64) plus_4_or_more(
        next_pc,
        pc_sel,
        {
            1'b0, pc_plus_4,
            1'b1, offset_pc
        }
    );

    pc pc_instance(sys_clk,sys_rst,next_pc,now_pc);
    // pc_adder pc_adder_instance(sys_clk,sys_rst,now_pc,pc_plus_4);
    always @(*) begin
        if(~stall_id_reg)begin
            pc_plus_4 = now_pc+4;
        end
        else
            pc_plus_4 = now_pc;
    end

imem_rom imem (
  .clka(sys_clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(next_pc[12:2]),  // input wire [10 : 0] addra
  .douta(instruction)  // output wire [31 : 0] douta
);



endmodule