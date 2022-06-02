`include "para.v"
module ysyx_22040383_mem (
    input sys_clk,
    input sys_rst,
    input [1:0] wb_select,
    input [`ysyx_22040383_width] pc_plus_4,
    input [`ysyx_22040383_width] read_addr,
    input [`ysyx_22040383_width] alu_res,
    input [`ysyx_22040383_width] rs2_data,
    input [7:0] write_width,
    input write_enable,
    output reg [`ysyx_22040383_width] unprocess_data
);
reg [`ysyx_22040383_width] dmem_data;
wire [`ysyx_22040383_width] dpic_data;
// reg [63:0] shift_bits;
// wire [`ysyx_22040383_width] unprocess_data;
// reg [`ysyx_22040383_width] interim;
import "DPI-C" function void pmem_read(
  input longint raddr, output longint rdata);
import "DPI-C" function void pmem_write(
  input longint waddr, input longint wdata, input byte wmask);
always @(posedge sys_clk) begin
    if (write_enable) 
        pmem_write(alu_res, rs2_data, write_width);
end
always @(posedge sys_clk) begin
      pmem_read(read_addr, dpic_data);
      dmem_data <= (dpic_data >>>(read_addr%8)*8);
end

// always @(posedge sys_clk) begin
//   shift_bits<=(alu_res%8)*8;
// end
MuxKey #(4,2,64) plus_4_or_more(
        unprocess_data,
        wb_select,
        {
            2'b00, alu_res,
            2'b01, dmem_data,
            2'b10, pc_plus_4,
            2'b11, alu_res  //not used
        }
    );
endmodule