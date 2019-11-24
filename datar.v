`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:15 10/31/2019 
// Design Name: 
// Module Name:    datar 
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
module datar(clk,rst_n,data_in,data_out,start
    );
	input clk;
	input rst_n;
	input [15:0] data_in;
	output reg [15:0] data_out;
	output start;
	
parameter N=250_000_00;

reg [25:0] cnt;
reg clk_1ms;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
cnt<=0;
end
else if(cnt==N-1)
cnt<=0;
else cnt<=cnt+1;
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
clk_1ms<=0;
end
else if(cnt==N-1)
clk_1ms<=~clk_1ms;
else ;
end

reg clk_r;
reg clk_rr;
wire start;

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
clk_r<=0;
clk_rr<=0;
end
else
begin
clk_r<=clk_1ms;
clk_rr<=clk_r;
end
end

assign start=clk_r&(~clk_rr);


always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
data_out<=0;
end
else if(start==1)
begin
data_out<=data_in;
end
else 
data_out<=data_out;
end

endmodule
