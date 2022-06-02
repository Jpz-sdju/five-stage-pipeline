`include "para.v"
module ysyx_22040383_alu (
    input [`ysyx_22040383_width] a,
    input [`ysyx_22040383_width] b,
    input [3:0] alu_op,
    output reg [`ysyx_22040383_width] c,
    input sub_as_carry,
    output reg cout
);
    
    // reg [`ysyx_22040383_width] interim;

    always @(*) begin
        if (alu_op == `ysyx_22040383_alu_add) begin
            {cout,c} = a + b + {64'b0,sub_as_carry};
        end 
        else case (alu_op)
            // `ysyx_22040383_alu_sub: c = a + ~b+1;
            `ysyx_22040383_alu_sl: c=a<<b;
            `ysyx_22040383_alu_sr: c=a>>b;
            `ysyx_22040383_alu_xor:c=a^b;
            `ysyx_22040383_alu_or: c = a | b;
            `ysyx_22040383_alu_and: c= a&b;
            `ysyx_22040383_alu_sra: c=$signed(a)>>>b;
            `ysyx_22040383_alu_mul: c=(a*b);
            `ysyx_22040383_alu_div: c=a/b;
            `ysyx_22040383_alu_rem: c=a%b;
            default: c=0;
        endcase
        cout = 1'bz;
    end
endmodule