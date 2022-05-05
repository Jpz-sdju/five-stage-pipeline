`include "para.v"
module alu (
    input [`width] a,
    input [`width] b,
    input [3:0] alu_op,
    output reg [`width] c,
    input sub_as_carry,
    output reg cout
);
    
    // reg [`width] interim;

    always @(*) begin
        if (alu_op == `alu_add) begin
            {cout,c} = a + b + {64'b0,sub_as_carry};
        end 
        else case (alu_op)
            // alu_sub: c = a + ~b+1;
            `alu_sl: c=a<<b;
            `alu_sr: c=a>>b;
            `alu_xor:c=a^b;
            `alu_or: c = a | b;
            `alu_and: c= a&b;
            `alu_sra: c=a>>>b;
            `alu_mul: c=(a*b);
            `alu_div: c=a/b;
            `alu_rem: c=a%b;
            default: c=0;
        endcase
        cout = 1'bz;
    end
endmodule