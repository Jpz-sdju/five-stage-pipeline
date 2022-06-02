`include "para.v"
module ysyx_22040383_wb (
    input [`ysyx_22040383_width] fake_write_back_data,
    input [4:0] fake_write_back_addr,
    input fake_is_write_rf,
    output reg [`ysyx_22040383_width] real_write_back_data,
    output [4:0] real_write_back_addr,
    output real_is_write_rf

);
    assign real_write_back_addr = fake_write_back_addr;
    assign real_is_write_rf = fake_is_write_rf;
    assign real_write_back_data =fake_write_back_data;
endmodule