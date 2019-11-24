`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:30:22 10/23/2018 
// Design Name: 
// Module Name:    bps_clk 
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
module bps_clk(
                input 			clk       ,
				input 			rst_n     ,
				input 			cnt_start ,
				output reg 		clk_bps
    );

    parameter bps_DR = 13'd5207;   //波特率为9600HZ
	 reg [12:0]div_cnt;
	
	always@(posedge clk  or negedge rst_n)  //分频计数模块
	begin
	      if(!rst_n)
		        div_cnt <= 13'd0;
		  else if(cnt_start) begin     //检测到下降沿信号开始计数
		       if(div_cnt==bps_DR)
		             div_cnt <= 13'd0;
               else          
		             div_cnt <= div_cnt + 1;
	      end
		  else 
		        div_cnt <= 13'd0;
    end

	
	
	always@(posedge clk  or negedge rst_n)   //bps_clk时钟产生模块
	begin
	     if(!rst_n)
                clk_bps <= 1'b0;
         else if(div_cnt == 13'd2603)  //为了得到稳定的数据在数据中间读数
                clk_bps <= 1'b1;
         else
                clk_bps <= 1'b0;
    end		


endmodule
