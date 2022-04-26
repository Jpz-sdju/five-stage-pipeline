`include "para.v"
module mem_wb (
    input sys_clk,
    input sys_rst,
    input [1:0] wb_select,
               input [`WIDTH] pc_plus_4,
               input [`WIDTH] alu_res,
               input [`WIDTH] rs2,
               input [7:0] write_width,
               input write_enable,
               output [`WIDTH] write_back_data,
               output [`WIDTH] vmem_data
               );
    
    reg [7:0] dmem[0:127];
    initial $readmemh("N:/vmshare/riscv-relevant/data.txt",dmem);
    reg [7:0] vmem[7:0];
    reg [2:0]cnter;
    always @(posedge sys_clk) begin
        vmem[cnter] <= dmem[cnter+7'd120];
    end
    always @(posedge sys_clk) begin
        if (~sys_rst) begin
            cnter<=0;
        end
        else cnter<=cnter+1;
    end
    assign vmem_data = {vmem[7],vmem[6],vmem[5],vmem[4],vmem[3],vmem[2],vmem[1],vmem[0]};
    wire [`WIDTH] dmem_data = {dmem[alu_res+7],dmem[alu_res+6],dmem[alu_res+5],dmem[alu_res+4],dmem[alu_res+3],dmem[alu_res+2],dmem[alu_res+1],dmem[alu_res]};
    
    always @(posedge sys_clk) begin
        if (write_enable ) begin
            case (write_width)
                8'b1:dmem[alu_res] = rs2[7:0];
                8'b11:begin
                    dmem[alu_res] = rs2[7:0];
                    dmem[alu_res+1] = rs2[15:8];
                end
                8'b1111:begin
                    dmem[alu_res] = rs2[7:0];
                    dmem[alu_res+1] = rs2[15:8];
                    dmem[alu_res+2] = rs2[24:16];
                    dmem[alu_res+3] = rs2[31:25];
                end 
            endcase
        end
    end
    MuxKey #(4,2,64) plus_4_or_more(
    write_back_data,
    wb_select,
    {
    2'b00, alu_res,
    2'b01, dmem_data,
    2'b10, pc_plus_4,
    2'b11, alu_res  //not used
    }
    
    
    
    
    );
    // import "DPI-C" function void pmem_read(
    //   input longint raddr, output longint rdata);
    // import "DPI-C" function void pmem_write(
    //   input longint waddr, input longint wdata, input byte wmask);
    // always @(*) begin
    //     if (write_enable)
    //         pmem_write(alu_res, rs2, write_width);
    // end
    // always @(*) begin
    //       pmem_read(alu_res, dmem_data);
    //       dmem_data = dmem_data >>(alu_res%8)*8;
    // end
    
endmodule
