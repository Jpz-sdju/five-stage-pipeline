`include "para.v"
module wb (
    input [`width] fake_write_back_data,
    input [4:0] fake_write_back_addr,
    output [`width] real_write_back_data,
    output [4:0] real_write_back_addr
);
    assign real_write_back_addr = fake_write_back_addr;
    assign real_write_back_data = fake_write_back_data;
endmodule