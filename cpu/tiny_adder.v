`include "para.v"
module ysyx_22040384_tiny_adder (
    input [`width] a,
    input [`width] b,
    output [`width] c
);
    assign c = a+b;    
endmodule