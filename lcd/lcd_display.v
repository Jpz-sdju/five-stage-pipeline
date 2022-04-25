`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/27 01:12:32
// Design Name: 
// Module Name: lcd_display
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


module lcd_display(
    input                lcd_clk,    //时钟
    input                sys_rst,       //复位，低电平有效
    input        [10:0]  x_pos,  //当前像素点横坐标
    input        [10:0]  y_pos,  //当前像素点纵坐标  
    output  reg  [23:0]  colorbar_data   //像素数据
    );

//parameter define  
parameter WHITE = 24'hFFFFFF;  //白色
parameter BLACK = 24'h000000;  //黑色
parameter RED   = 24'hFF0000;  //红色
parameter GREEN = 24'h00FF00;  //绿色
parameter BLUE  = 24'h0000FF;  //蓝色

parameter  H_DISP_4384  = 11'd800;
parameter  V_DISP_4384  = 11'd480;

//根据当前像素点坐标指定当前像素点颜色数据，在屏幕上显示彩条
always @(posedge lcd_clk or negedge sys_rst) begin
    if(!sys_rst)
        colorbar_data <= BLACK;
    else begin
        if((x_pos >= 11'd0) && (x_pos < H_DISP_4384/5*1))
            colorbar_data <= WHITE;
        else if((x_pos >= H_DISP_4384/5*1) && (x_pos < H_DISP_4384/5*2))    
            colorbar_data <= BLACK;
        else if((x_pos >= H_DISP_4384/5*2) && (x_pos < H_DISP_4384/5*3))    
            colorbar_data <= RED;   
        else if((x_pos >= H_DISP_4384/5*3) && (x_pos < H_DISP_4384/5*4))    
            colorbar_data <= GREEN;                
        else 
            colorbar_data <= BLUE;      
    end    
end
  
endmodule
