`include "para.v"
module mem (
    input sys_clk,
    input sys_rst,
    input op_sb,
    input op_sh,
    input op_sw,
    input [1:0] wb_select,
    input [`width] pc_plus_4,
    input [`width] read_addr,
    input [`width] alu_res,
    input [`width] rs2_data,
    input [7:0] write_width,
    input write_enable,
    output [`width] unprocess_data,
    output reg [63:0] vmem_reg
);
wire [`width] dmem_data;
// reg [63:0] vmem_reg;
wire [7:0] yanma = write_width << read_addr[2:0];
// wire [63:0] extended_yanma = { {yanma[7]?8'b11111111:8'b0}, {yanma[6]?8'b11111111:8'b0}, {yanma[5]?8'b11111111:8'b0}, {yanma[4]?8'b11111111:8'b0}, {yanma[3]?8'b11111111:8'b0}, {yanma[2]?8'b11111111:8'b0}, {yanma[1]?8'b11111111:8'b0}, {yanma[0]?8'b11111111:0}};
wire [63:0] extended_yanma ;
assign extended_yanma[7:0] =  yanma[0]?8'b11111111:0;
assign extended_yanma[15:8] =  yanma[1]?8'b11111111:0;
assign extended_yanma[23:16] =  yanma[2]?8'b11111111:0;
assign extended_yanma[31:24] =  yanma[3]?8'b11111111:0;
assign extended_yanma[39:32] =  yanma[4]?8'b11111111:0;
assign extended_yanma[47:40] =  yanma[5]?8'b11111111:0;
assign extended_yanma[55:48] =  yanma[6]?8'b11111111:0;
assign extended_yanma[63:56] =  yanma[7]?8'b11111111:0;
wire [`width] write_in_data = op_sb? {8{rs2_data[7:0]}}:
                              op_sh? {4{rs2_data[15:0]}}:
                              op_sw? {2{rs2_data[31:0]}}:
                              rs2_data;
always @(posedge sys_clk) begin
    if (sys_rst) begin
        vmem_reg<=0;
    end
    else if(read_addr[12:3] == 10'b0000001111 && write_enable)begin
        vmem_reg<=(vmem_reg & ~extended_yanma) |(write_in_data & extended_yanma);
        // vmem_reg<=dmem_data;
    end
end
dmem dmem_ins (
  .clka(sys_clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(write_enable?yanma:8'b0),      // input wire [7 : 0] wea
  .addra(read_addr[12:3]),  // input wire [9 : 0] addra
  .dina(write_in_data),    // input wire [63 : 0] dina
  .douta(dmem_data)  // output wire [63 : 0] douta
);
wire [5:0] shift = alu_res[2:0]<<3;
wire [63:0]bala = dmem_data>>shift;
MuxKey #(4,2,64) plus_4_or_more(
        unprocess_data,
        wb_select,
        {
            2'b00, alu_res,
            2'b01, bala,
            2'b10, pc_plus_4,
            2'b11, alu_res  //not used
        }
    );
endmodule