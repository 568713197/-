`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:36 10/07/2019 
// Design Name: 
// Module Name:    P2 
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
/*
module  p2(
				clk,
				rst_n,
				da_in,
				pwm_out
);

input					clk;
input					rst_n;
input   [2:0]   	da_in;
output	reg		pwm_out;

parameter CT=26'd125_000_000; 

reg [25:0] cnt1;
reg [30:0] cnt;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
cnt1<=0;
else if(cnt1==CT-1)
cnt1<=0;
else 
cnt1<=cnt1+1;
end

reg clr;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
clr<=0;
else if(cnt1==CT-1)
clr<=~clr;
else
clr<=clr;
end


parameter           s=1000_000,//20ms-----T
					s0=125_000,//2.5ms
					s1=90_000,//90
					s2=55_000,//180
					s3=25_000;//270
					
									
reg	[31:0]  cnt_r;	

reg 	[2:0]    da_in_r;

always@(posedge clr or negedge rst_n)begin
	if(!rst_n)
		da_in_r <= 4'd0;
	else 
		da_in_r <= da_in;
end



always@(*)begin
	if(!rst_n)
		cnt_r <= 31'd0;
	else
		begin
			case(da_in_r)
				3'b000: cnt_r <= s0;
			    3'b001: cnt_r <= s2;
				3'd010: cnt_r <= s2;
				3'd100: cnt_r <= s2;
				default: cnt_r <= s0;
			endcase
		end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt <= 31'd0;
	else if(cnt >= s)
		cnt <= 31'd0;
	else
		cnt <= cnt + 1'b1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		pwm_out <= 1'b0;
	else if(cnt <= cnt_r)
		pwm_out <= 1'b1;
	else
		pwm_out <= 1'b0;
end




endmodule

module plus_delay(
        CLK  ,
		Delay_IN,	 
		Delay_OUT ,  
		Plus
	      );
		input     CLK  ;	 
		input     Delay_IN  ;	//输入脉冲
		output    Delay_OUT; //延时后的输出脉冲
		output    Plus;      //
		//-----------------------------------////
     reg [7:0] delay_plus;
	 reg Delay_plus;
	 reg plus_flag;
	 
	 wire plus;
	 assign Delay_OUT = Delay_plus;
	always @(posedge CLK)
	begin
		plus_flag<=Delay_IN;
	end
	
	assign plus=~plus_flag&Delay_IN;   // 正脉冲检测
	assign Plus=plus;
	  	
	always @(posedge plus or posedge CLK)
	begin
		if(plus==1'b1)
		begin
			delay_plus[7:0]<=8'h0;
			Delay_plus<= 1'b0;
		// clk_temp<=1'b0;
		end								 
		else
		begin						 			
			if(delay_plus[7:0]==16'h5F)// 100=95+5（延时时间=原脉宽高电平时间5us + 延时计数次数*时钟周期）
			begin
				delay_plus[7:0] <= delay_plus[7:0]+1'b1;
				Delay_plus<= 1'b1;
			end
			else 
			begin
				Delay_plus<= Delay_plus;
				delay_plus[7:0] <= delay_plus[7:0]+1'b1;
			end		
		end       						  
	end 
	      
endmodule	      
	  */    

module  p2(
			clk,rst_n,sign,pwm_out
    );
input rst_n;
input  clk;
output reg pwm_out;
input sign;
wire pos;

parameter CT=100_000_000;

reg [26:0] cnt1;
reg sign0,sign1,sign2;
reg [1:0] key;
 reg [1:0] cs;
reg [1:0] bs;
always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
sign0<=0;
sign1<=0;
sign2<=0;
end
else
 begin
sign0<=sign;
sign1<=sign0;
sign2<=sign1;
end

assign pos=~sign2&sign1;


always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
cnt1<=0;
else if(pos==1)
cnt1<=0;
else if(cnt1==CT-1)
cnt1<=0;
else 
cnt1<=cnt1+1;
end


reg clr;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
clr<=0;
else if(cnt1==CT-1)
clr<=1;
else
clr<=0;
end


always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
key<=2'b0;
else if(pos==1)
key<=2'b0;
else if(key==2'b11)
key<=2'b11;
else if(clr==1)
key<=key+1;
else;
end

parameter h1=2'b01;
parameter h2=2'b10;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
cs<=h1;
else
cs<=bs;
end

always@(*)
begin
case(cs)
h1 : if(key==2'b01)
        bs<=h2;
	else
	     bs<=h1;
h2 : if(key==2'b10||key==2'b00||key==2'b11)
        bs<=h1;
	else
	     bs<=h2;
default : bs<=h1;
endcase
end

reg [30:0] cnt;

parameter           s=1000_000,//20ms-----T
					s0=125_000,//2.5ms0
					s1=107_500;//45
					
									
reg	[31:0]  cnt_r;	



always@(*)begin
	if(!rst_n)
		cnt_r <= 31'd0;
	else
		begin
			case(cs)
				h1: cnt_r <= s0;
			    h2: cnt_r <= s1;
				default: cnt_r <= s0;
			endcase
		end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt <= 31'd0;
	else if(cnt >= s)
		cnt <= 31'd0;
	else
		cnt <= cnt + 1'b1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		pwm_out <= 1'b0;
	else if(cnt <= cnt_r)
		pwm_out <= 1'b1;
	else
		pwm_out <= 1'b0;
end



  
endmodule