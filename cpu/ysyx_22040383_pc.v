
`include "para.v"
module ysyx_22040383_pc(
    input clk,
    input rst,
    input [`ysyx_22040383_width] next_pc,
    output [`ysyx_22040383_width] now_pc
);
    Reg #(64,64'h7ffffffc) pc_reg(clk,rst,next_pc,now_pc,1'b1);
endmodule