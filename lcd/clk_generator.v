`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/25 17:38:03
// Design Name:
// Module Name: clk_generator
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


module clk_generator(input sys_clk,
                     input sys_rst,
                     output reg lcd_clk);
    reg clk_25hz;
    
    // always @(*) begin
    //     case (lcd_model)
    //         16'h4342:lcd_clk <= clk_12_5hz;
    //         16'h7084:lcd_clk <= clk_25hz;
    //         16'h7016:lcd_clk <= sys_clk;
    //         16'h4384:lcd_clk <= clk_25hz;
    //         16'h1018:lcd_clk <= sys_clk;
    //     endcase
    // end
    
    always @(*) begin
        lcd_clk <= clk_25hz;
    end
    always @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)begin
            clk_25hz <= 0;
        end
        else begin
            clk_25hz <= clk_25hz +1;
        end
    end
endmodule
