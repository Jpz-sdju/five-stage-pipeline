`include "para.v"
module exu (
    input [`width] a,
    input [`width] b,
    output [`width] res,
    input [3:0] alu_op,
    input sub,
    input slt_and_spin_off_signed,
    input slt_and_spin_off_unsigned,
    input word_op
);
    wire [`width] tricked_b;
    wire [`width] alu_res;
    wire cout;

    wire [`width] word_judged_a = word_op?{32'b0,a[31:0]}:a;
    wire [`width] word_judged_b = word_op?{32'b0,b[31:0]}:b;

    wire contrary_signed =a[63] ^ b[63];
    wire slt_contrary_signed = contrary_signed&&slt_and_spin_off_signed;
    
    wire [`width]one_bit_res;
    alu u_alu(
        word_judged_a,
        tricked_b,
        alu_op,
        alu_res,
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