
`include "para.v"
module pc(
    input clk,
    input rst,
    input [`WIDTH] next_pc,
    output [`WIDTH] now_pc
);
    Reg #(64,64'h00000000) pc_reg(clk,rst,next_pc,now_pc,1'b1);
endmodule