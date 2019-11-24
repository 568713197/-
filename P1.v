`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:12:16 10/26/2019 
// Design Name: 
// Module Name:    P1 
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
module p1(
				clk,
				rst_n,
				da_in,
				pwm_out,
				data
);

input					clk;
input				rst_n;
input   [7:0]   	da_in;
output	reg		pwm_out;
output reg [3:0] data;

reg [20:0] cnt;
parameter h=850000;//20x5ns   200000slow350000
reg [20:0] cnt2;

parameter           s=1000_000,//20ms-----T
					s0=124_000,//2.5ms
					s1=90_000,//90
					s2=55_000,//180
					s3=20_000;//270
					/*
					 s=100,//20ms-----T
					s0=50,//2.5ms
					s1=40,//90
					s2=30,//180
					s3=20;//270
					*/
									
reg	[20:0]  cnt_r;	
reg [20:0]  cntr;
reg 	[7:0]    da_in_r;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		da_in_r <= 'b0;
	else 
		da_in_r <= da_in;
end



always@(*)begin
	if(!rst_n)
		cnt_r <= 'd0;
	else
		begin
			case(da_in_r)
				'd49: cnt_r <= s0;
			    'd50: cnt_r <= s1;
				'd51: cnt_r <= s2;
				'd52: cnt_r <= s3;
				default: cnt_r <= s0;
			endcase
		end
end


always@(posedge clk or negedge rst_n)
if(!rst_n)
cntr<=s0;
else if(cntr==cnt_r)
cntr<=cntr;
else if(cntr>cnt_r)
begin
if(cntr>cnt_r&&cnt2==h)
cntr<=cntr-'d1000;//1000
else
cntr<=cntr;
end
else begin
if(cntr<cnt_r&&cnt2==h)
cntr<=cntr+'d1000;
else
cntr<=cntr;
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt <= 'd0;
	else if(cnt >= s)
		cnt <= 'd0;
	else
		cnt <= cnt + 1'b1;
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt2 <= 'd0;
	else if(cnt2 >= h)
		cnt2 <= 'd0;
	else
		cnt2 <= cnt2 + 1'b1;
end



always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		pwm_out <= 1'b0;
	else if(cnt <= cntr)
		pwm_out <= 1'b1;
	else
		pwm_out <= 1'b0;
end

	 always@(*)
		case(cntr)
		s0 :data='b0001;
		s1 :data='b0010;
		s2 :data='b0100;
		s3 :data='b1000;
		default: data='b0000;
		endcase


endmodule