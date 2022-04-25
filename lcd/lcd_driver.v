`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/27 01:11:41
// Design Name:
// Module Name: lcd_driver
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


module lcd_driver(input clk_from_display,
                  input sys_rst,
                  input [23:0] data_from_display,
                  output [10:0]x_pos,
                  output [10:0]y_pos,
                  output de,
                  output hsync,
                  output vsync,
                  output reg lcd_bl,
                  output lcd_clk,
                  output [23:0] rgb_data,
                  output reg lcd_rst);
    
    parameter  H_SYNC_4384  = 11'd128;
    parameter  H_BACK_4384  = 11'd88;
    parameter  H_DISP_4384  = 11'd800;
    parameter  H_FRONT_4384 = 11'd40;
    parameter  H_TOTAL_4384 = 11'd1056;
    
    parameter  V_SYNC_4384  = 11'd2;
    parameter  V_BACK_4384  = 11'd33;
    parameter  V_DISP_4384  = 11'd480;
    parameter  V_FRONT_4384 = 11'd10;
    parameter  V_TOTAL_4384 = 11'd525;
    
    assign hsync   = 1;
    assign vsync   = 1;
    assign lcd_clk = clk_from_display;
    
    
    reg [10:0] counter_h;
    reg [10:0] counter_v;


    
    wire data_req;
    assign  de = ((counter_h > H_SYNC_4384 + H_BACK_4384) && (counter_h < H_SYNC_4384 + H_BACK_4384 + H_DISP_4384)
    && (counter_v > V_SYNC_4384 + V_BACK_4384) && (counter_v < V_SYNC_4384 + V_BACK_4384 + V_DISP_4384))? 1'b1 : 1'b0;
    assign data_req = de;
    
    assign x_pos = data_req?(counter_h -H_SYNC_4384 - H_BACK_4384 ):11'b0;
    assign y_pos = data_req?(counter_v -V_SYNC_4384 - V_BACK_4384 ):11'b0;
    
    assign rgb_data = de?data_from_display:24'b0;
    


    always @(posedge clk_from_display or negedge sys_rst) begin //h counter
        if (!sys_rst) begin
            counter_h <= 0;
        end
        else begin
            if (counter_h == H_TOTAL_4384 -1)
            begin
                counter_h <= 0;
            end
            else
                counter_h <= counter_h+1;
        end
    end
    
    always @(posedge clk_from_display or negedge sys_rst) begin //v counter
        if (!sys_rst)
            counter_v <= 0;
        else begin
            if (counter_h == H_TOTAL_4384 -1) begin
                if (counter_v == V_TOTAL_4384 -1)
                    counter_v <= 0;
                else
                    counter_v <= counter_v+1;
            end
        end
    end
    
    always @(posedge clk_from_display) begin
        if (!sys_rst)begin
            lcd_bl  <= 0;
            lcd_rst <= 0;
        end
        else begin
            lcd_bl  <= 1;
            lcd_rst <= 1;
        end
    end
endmodule
