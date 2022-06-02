
`include "para.v"
module pc(
    input clk,
    input rst,
    input [`width] next_pc,
    output [`width] now_pc
);
    Reg #(64,64'h7ffffffc) pc_reg(clk,rst,next_pc,now_pc,1'b1);
endmodule