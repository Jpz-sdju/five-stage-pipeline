`include "para.v"
module exu (
    input [`WIDTH] a,
    input [`WIDTH] b,
    output [`WIDTH] res,
    input [2:0] alu_op,
    input sub,
    input slt_and_spin_off_signed,
    input slt_and_spin_off_unsigned
);
    wire [`WIDTH] tricked_b;
    wire [`WIDTH] alu_res;
    wire contrary_signed =a[63] ^ b[63];
    wire slt_contrary_signed = contrary_signed&&slt_and_spin_off_signed;
    wire cout;

    wire [`WIDTH]one_bit_res;
    alu u_alu(
        a,
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
            1'b0,b,
            1'b1,~b
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