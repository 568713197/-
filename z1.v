`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:20:59 10/26/2019 
// Design Name: 
// Module Name:    z1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Z1(
clk,rst_n,pwm_out1,pwm_out2,rs232_rx,led
    );
input clk;
input rst_n;
input rs232_rx;
output pwm_out1;
output pwm_out2;
output [3:0] led;
wire pos;
wire [7:0] in;
wire rx_done;
 p1 u1(
        .clk(clk),
		.rst_n(rst_n),
		.da_in(in),
		.data(led),
		.pwm_out(pwm_out1)
 );
 
 p2 u2( 
        .pos(pos),
        .clk(clk),
		.rst_n(rst_n),
		.pwm_out(pwm_out2)
 );
 
 p3 u3( .pos(pos),
        .clk(clk),
		.rx_done(rx_done),
		.rst_n(rst_n),
		.sign(sign)
 );

 data u4(.clk(clk),
		 .rst_n(rst_n),
		 .data_in(in),//输入
		 .sign(sign)
 );
 
 rx  u5(     .clk(clk),        //模块时钟50M
			.rst_n(rst_n),      //模块复位
			.rs232_rx(rs232_rx),   //RS232数据输入
			.rx_done(rx_done),
			.data_byter(in),
			.data()
 );

endmodule