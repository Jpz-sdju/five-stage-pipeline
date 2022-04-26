`include "para.v"
module alu (
    input [`WIDTH] a,
    input [`WIDTH] b,
    input [2:0] alu_op,
    output reg [`WIDTH] c,
    input sub_as_carry,
    output reg cout
);
    


    always @(*) begin
        if (alu_op == `alu_add) begin
            {cout,c} = a + b + {64'b0,sub_as_carry};
        end else
        case (alu_op)
            // `alu_sub: c = a + ~b+1;
            `alu_sl: c=a<<b;
            `alu_sr: c=a>>b;
            `alu_xor:c=a^b;
            `alu_or: c = a | b;
            `alu_and: c= a&b;
            default: c=0;
        endcase
        cout = 1'bz;
    end
endmodule