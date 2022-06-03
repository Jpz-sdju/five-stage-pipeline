`include "para.v"
module mem (
    input sys_clk,
    input sys_rst,
    input [1:0] wb_select,
    input [`width] pc_plus_4,
    input [`width] read_addr,
    input [`width] alu_res,
    input [`width] rs2_data,
    input [7:0] write_width,
    input write_enable,
    output reg [`width] unprocess_data
);
reg [`width] dmem_data;
reg [63:0] vmem_reg;
wire [7:0] yanma = write_width << read_addr[2:0];
wire [63:0] extended_yanma = { {yanma[7]?8'b11111111:8'b0}, {yanma[6]?8'b11111111:8'b0}, {yanma[5]?8'b11111111:8'b0}, {yanma[4]?8'b11111111:8'b0}, {yanma[3]?8'b11111111:8'b0}, {yanma[2]?8'b11111111:8'b0}, {yanma[1]?8'b11111111:8'b0}, {yanma[0]?8'b11111111:0}};
always @(posedge sys_clk) begin
    if(read_addr[12:3] == 10'b1111111111 && write_enable)begin
        vmem_reg<=(vmem_reg & ~extended_yanma) |(rs2_data & extended_yanma);
    end
end
dmem dmem_ins (
  .clka(sys_clk),    // input wire clka
  .ena(write_enable),      // input wire ena
  .wea(yanma),      // input wire [7 : 0] wea
  .addra(read_addr[12:3]),  // input wire [9 : 0] addra
  .dina(rs2_data),    // input wire [63 : 0] dina
  .douta(dmem_data)  // output wire [63 : 0] douta
);
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