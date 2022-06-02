module regfile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
  input sys_clk,
  input [ADDR_WIDTH-1:0] raddr1,
  input [ADDR_WIDTH-1:0] raddr2,

  input [ADDR_WIDTH-1:0] waddr,
  input [DATA_WIDTH-1:0] wdata,

  output [DATA_WIDTH-1:0] rdata1,
  output [DATA_WIDTH-1:0] rdata2,
  input wen
);


  reg [DATA_WIDTH-1:0] rf [ADDR_WIDTH-1:0];

  always @(posedge sys_clk) begin
    if (wen&&(waddr!=0) ) rf[waddr] <= wdata;
  end

  assign rdata1 = rf[raddr1];
  assign rdata2 = rf[raddr2];
endmodule
