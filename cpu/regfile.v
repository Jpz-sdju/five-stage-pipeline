module regfile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
  input sys_clk,
  input sys_rst,
  input [4:0] raddr1,
  input [4:0] raddr2,

  input [4:0] waddr,
  input [DATA_WIDTH-1:0] wdata,

  output [DATA_WIDTH-1:0] rdata1,
  output [DATA_WIDTH-1:0] rdata2,
  input wen
);


  reg [DATA_WIDTH-1:0] rf [ADDR_WIDTH-1:0];
  integer i;
  always @(posedge sys_clk) begin
    if (sys_rst) begin
      for (i = 0;i<=31 ;i=i+1 ) begin
        rf[i] <=0;
      end
    end
    else if (wen&&(waddr!=0) ) rf[waddr] <= wdata;
  end

  assign rdata1 = rf[raddr1];
  assign rdata2 = rf[raddr2];
endmodule
