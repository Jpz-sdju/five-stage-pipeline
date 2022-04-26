`include "para.v"
module compare (
    input [`WIDTH] a,
    input [`WIDTH] b,
    output equal,
    output less_than,
    output u_less_than
);
    assign equal = a==b?1'b1:1'b0;
    assign less_than = $signed(a)<$signed(b)?1'b1:1'b0;
    assign u_less_than = a<b?1'b1:1'b0;
endmodule