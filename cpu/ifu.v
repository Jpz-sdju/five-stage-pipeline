`include "para.v"
module ifu (input sys_clk,
            input sys_rst,
            input [`WIDTH] offset_pc,
            input pc_sel,
            output [`WIDTH] now_pc,
            output [`WIDTH] pc_plus_4,
            output [31:0] instruction);
    wire [`WIDTH] next_pc;
    MuxKey #(2,1,64) plus_4_or_more(
    next_pc,
    pc_sel,
    {
    1'b0, pc_plus_4,
    1'b1, offset_pc
    }
    );
    
    pc pc_instance(sys_clk,sys_rst,next_pc,now_pc);
    pc_adder pc_adder_instance(sys_clk,sys_rst,now_pc,pc_plus_4);
    
    wire [7:0] addr = now_pc[9:2];
    
    imem your_instance_name (
    .a(addr),      // input wire [7 : 0] a
    .spo(instruction)  // output wire [31 : 0] spo
    );
    // wire [`WIDTH] dpic_data;
    // assign instruction = ((now_pc- 64'h80000000)/4)%2 == 1?dpic_data[63:32]:dpic_data[31:0];
    
    //------------------------------------dpi-c-------------------------
    // import "DPI-C" function void pmem_read(
    //         input longint raddr, output longint rdata);
    //     always @(*) begin
    //         pmem_read(now_pc, dpic_data);
    //     end
    //--------------------------------------------------------------------------------
    
    
    
endmodule
