`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/03/30 20:51:00
// Design Name:
// Module Name: font_display
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


module font_display(input lcd_clk,                    //时钟
                    input sys_rst,                    //复位，低电平有效
                    input [10:0] x_pos,               //当前像素点横坐标
                    input [10:0] y_pos,               //当前像素点纵坐标
                    output reg [23:0] colorbar_data, //像素数据
                    input [11:0] lrom_offset,
                    output reg vmem_enable
                    );
    //parameter define
    // reg [511:0] font [127:0];
    
    localparam CHAR_X_START = 11'd1; //字符起始点横坐标
    localparam CHAR_Y_START = 11'd1; //字符起始点纵坐标
    localparam CHAR_WIDTH   = 11'd256; //字符宽度,
    localparam CHAR_HEIGHT  = 11'd64; //字符高度
    
    wire [10:0] x_cnt;
    wire [10:0] y_cnt;
    
    assign x_cnt = x_pos - CHAR_X_START;
    assign y_cnt = y_pos - CHAR_Y_START;
    
    
    localparam BACK_COLOR = 24'hE0FFFF;
    localparam CHAR_COLOR = 24'hff0000;
    
    wire [11:0]addra;
    wire [31:0]dout;
    reg [5:0] addr_cnt;
    reg [5:0]row_offset;
    // initial begin
    //     $readmemh("C:/Users/renge/Desktop/dd.txt",font);
    // end
    // always @(posedge lcd_clk or negedge sys_rst) begin
    //     if (!sys_rst)
    //     begin
    //         colorbar_data <= BACK_COLOR;
    //         addra         <= 0;
    //     end
    //     else if ((x_pos > = CHAR_X_START) && (x_pos < CHAR_X_START + CHAR_WIDTH)&& (y_pos > = CHAR_Y_START) && (y_pos < CHAR_Y_START + CHAR_HEIGHT)) begin
    //         if (font[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
    //             colorbar_data <= CHAR_COLOR;
    //         else
    //             colorbar_data <= BACK_COLOR;
    //     end
    //     else
    //         colorbar_data <= BACK_COLOR;
    // end
    
    
    always @(posedge lcd_clk or negedge sys_rst) begin
        if (!sys_rst)
            colorbar_data <= CHAR_COLOR;//this
        else if ((x_pos>= CHAR_X_START) && (x_pos < CHAR_X_START + CHAR_WIDTH)&& (y_pos>= CHAR_Y_START) && (y_pos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if (dout[CHAR_WIDTH -1'b1 - x_cnt])
            begin
                colorbar_data <= 24'h000000;
            end
            else
            begin
                colorbar_data <= BACK_COLOR;
            end
            // addr_cnt <= addr_cnt+1;
        end
        else
            colorbar_data <= BACK_COLOR;
    end
    
    assign addra = lrom_offset +row_offset;
    // always @(posedge lcd_clk or negedge sys_rst) begin
    //     if (!sys_rst)
    //     begin
    //         addr_cnt <= 0;
    //     end else if( (x_cnt >=0 && x_cnt< CHAR_WIDTH)&& (y_cnt>=0 && y_cnt <CHAR_HEIGHT) && addr_cnt!=5'd31)begin
    //         addr_cnt <=addr_cnt +1;

    //     end else if (addr_cnt == 5'd31)
    //         begin
    //         addr_cnt <= 0;
    //     end
    // end

    always @(posedge lcd_clk) begin         //ve signal
        if(!sys_rst)
        begin
            vmem_enable <=0;
        end
        else if ( (x_cnt >=0 && x_cnt< CHAR_WIDTH)&& (y_cnt>=0 && y_cnt <CHAR_HEIGHT)) begin
            vmem_enable <=1;
        end else
            vmem_enable <=0;
    end
    

    always @(posedge lcd_clk) begin
        if(!sys_rst)
            row_offset<=0;
        else if (y_cnt <=CHAR_HEIGHT) begin
            row_offset <=y_cnt;
        end else
            row_offset <=0;
    end
    
    // if (y_cnt<CHAR_HEIGHT) begin
    //     if (dout[CHAR_WIDTH -1 -x_cnt]) begin
    //         colorbar_data <= CHAR_COLOR;
    //         addra         <= y_cnt;
    //     end
    //     else colorbar_data <= BACK_COLOR;
    // end
    
    block_rom u_brom (
    .clka(lcd_clk),    // input wire clka
    .addra(addra),  // input wire [11 : 0] addra
    .douta(dout)  // output wire [31 : 0] douta
    );
    
endmodule
