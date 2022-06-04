module soc(input sys_clk,
           input sys_rst,
           output de,
           output hsync,
           output vsync,
           output lcd_clk,
           inout [23:0] data,
           output lcd_rst,
           output lcd_bl);
    wire [63:0]vmem_data;
    cpu u_cpu(
    	.sys_clk (sys_clk ),
        .sys_rst (sys_rst ),
        .vmem_reg(vmem_data)
    );
    
    
    lcd_top u_lcd_top(
    .sys_clk (sys_clk),
    .sys_rst (sys_rst),
    .de      (de),
    .vmem_data    (vmem_data),
    .hsync   (hsync),
    .vsync   (vsync),
    .lcd_clk (lcd_clk),
    .data    (data),
    .lcd_rst (lcd_rst),
    .lcd_bl  (lcd_bl)
    );
endmodule