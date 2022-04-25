`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/25 18:05:03
// Design Name:
// Module Name: lcd_id_receive
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


module lcd_id_receive(input sys_clk,
                      input sys_rst,
                      input [23:0] in_rgb_data,
                      output reg [15:0] lcd_model);
    reg is_received;
    always @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)begin
            lcd_model   <= 0;
            is_received <= 0;
        end
        else begin
            if (!is_received) begin
                is_received <= 1;
                case ({in_rgb_data[7],in_rgb_data[15],in_rgb_data[23]}) //M0:M2
                    3'b000: lcd_model <= 16'h4342;
                    3'b001: lcd_model <= 16'h7084;
                    3'b010: lcd_model <= 16'h7016;
                    3'b100: lcd_model <= 16'h4384;   //my lcd model
                    3'b101: lcd_model <= 16'h1018;
                endcase
            end
            
            
        end
    end
endmodule
