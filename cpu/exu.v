`include "para.v"
module exu (
    input [`width] a,
    input [`width] b,
    input [3:0] alu_op,
    input sub,
    input slt_and_spin_off_signed,
    input slt_and_spin_off_unsigned,
    input word_op,
    output [`width] res
);
    wire [`width] tricked_b;
    wire [`width] alu_res;
    wire [`width] pre_alu_res;
    wire cout;

    wire contrary_signed =a[63] ^ b[63];
    wire slt_contrary_signed = contrary_signed&&slt_and_spin_off_signed;
    // wire [`width] word_judged_a = word_op?
    // a[63]?{{32{1'b1}},a[31:0]}:{{32{1'b0}},a[31:0]}:a;
    // wire [`width] word_judged_b = word_op?
    // b[63]?{{32{1'b1}},b[31:0]}:{{32{1'b0}},b[31:0]}:b;

    wire [`width] word_judged_a = word_op?
    {{32{1'b0}},a[31:0]}:a;
    wire [`width] word_judged_b = word_op?
    {{32{1'b0}},b[31:0]}:b;

    wire [`width] word_extended_result = {{32{pre_alu_res[31]}},pre_alu_res[31:0]};
    wire [`width]one_bit_res;
    MuxKey #(2,1,64) word_extended_mux(
        alu_res,
        word_op,
        {
            1'b0,pre_alu_res,
            1'b1,word_extended_result
        }
    );
    alu u_alu(
        word_judged_a,
        tricked_b,
        alu_op,
        pre_alu_res,
        sub||(slt_and_spin_off_signed&&~contrary_signed)||slt_and_spin_off_unsigned,
        cout
    );
    MuxKey #(2,1,64) b_mux(
        tricked_b,
        sub||(slt_and_spin_off_signed&&~contrary_signed)||slt_and_spin_off_unsigned,
        {
            1'b0,word_judged_b,
            1'b1,~word_judged_b
        }
    );
    MuxKey #(2,1,64) slt_spin_off(
        res,
        slt_and_spin_off_signed||slt_and_spin_off_unsigned,
        {
            1'b0,alu_res,
            1'b1,one_bit_res
        }
    );

    MuxKey #(2,1,64) slt_accelerate(
        one_bit_res,
        slt_contrary_signed,
        {
            1'b0,{63'b0,~cout},
            1'b1,{63'b0,(a[63]==1'b1)?1'b1:1'b0}
        }
    );


    



endmodule