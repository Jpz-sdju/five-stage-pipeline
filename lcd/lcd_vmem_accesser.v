`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/04/14 01:14:17
// Design Name:
// Module Name: lcd_vmem_accesser
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module lcd_vmem_accesser(input sys_clk,
                         input sys_rst,
                         input [63:0] vmem_data,
                         output reg [11:0] lrom_offset,
                         input vmem_enable);
    
    
    reg [4:0] row_cnt;
    reg [2:0] vmem_addr;
    always @(posedge sys_clk) begin //when row_cnt == 32,addr change to next
        if (!sys_rst)
            row_cnt <= 0;
        else if (vmem_enable) begin
            if (row_cnt <= 5'b11111)
                row_cnt <= row_cnt+1;
            else
            row_cnt <= 0;
        end
        else
            row_cnt <= 0;
    end
    
    
    
    
    always @(posedge sys_clk) begin
        if (!sys_rst)
            vmem_addr <= 0;
        else if (vmem_enable) begin
            if (row_cnt == 5'b11111 && vmem_addr <= 3'b111)
                vmem_addr <= vmem_addr +1;
            else if (vmem_addr > 3'b111)
                vmem_addr <= 0;
        end
            else
                vmem_addr <= 0;
    end
            
            always @(*) begin
                case (vmem_addr)
                    3'b000: lrom_offset = vmem_data[7:0]*64;
                    3'b001: lrom_offset = vmem_data[15:8]*64;
                    3'b010: lrom_offset = vmem_data[23:16]*64;
                    3'b011: lrom_offset = vmem_data[31:24]*64;
                    3'b100: lrom_offset = vmem_data[39:32]*64;
                    3'b101: lrom_offset = vmem_data[47:40]*64;
                    3'b110: lrom_offset = vmem_data[55:48]*64;
                    3'b111: lrom_offset = vmem_data[63:56]*64;
                endcase
                
            end
            
            
            
            
            endmodule
