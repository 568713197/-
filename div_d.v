`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:58:00 10/17/2019 
// Design Name: 
// Module Name:    div_d 
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
module div(
				input clk,		//外部输入25MHz时钟信号
				input rst_n,	//外部输入复位信号，低电平有效
				output reg out
			);															
						
						
always @(posedge clk or negedge rst_n)
	if(!rst_n) out <= 0;
	else out<=out+1'b1;


endmodule
