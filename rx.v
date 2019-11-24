`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:48:27 10/31/2019 
// Design Name: 
// Module Name:    rx 
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
module rx(
			clk,        //模块时钟50M
			rst_n,      //模块复位
			rs232_rx,   //RS232数据输入
			data_byter,
			rx_done,
			data
			
		);

	input clk;
	input rst_n;
	input rs232_rx;
	reg [7:0]data_byte;
	output reg rx_done;
	output reg [3:0] data;
	output reg [7:0]data_byter;
	parameter baud_set=0;
	
	reg s0_Rs232_Rx,s1_Rs232_Rx;//同步寄存器
	
	reg tmp0_Rs232_Rx,tmp1_Rs232_Rx;//数据寄存器
	
	reg [15:0]bps_DR;//分频计数器计数最大值
	reg [15:0]div_cnt;//分频计数器
	reg bps_clk;//
	reg [7:0]bps_cnt;
	
	reg uart_state;
	
	reg [2:0] r_data_byte [7:0];
	//reg [7:0] tmp_data_byte;
	reg [2:0] START_BIT,STOP_BIT;
	
	 wire nedege;
	
	//同步寄存器，消除亚稳态
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		s0_Rs232_Rx <= 1'b0;
		s1_Rs232_Rx <= 1'b0;	
	end
	else begin
		s0_Rs232_Rx <= rs232_rx;
		s1_Rs232_Rx <= s0_Rs232_Rx;	
	end
	
	//数据寄存器
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		tmp0_Rs232_Rx <= 1'b0;
		tmp1_Rs232_Rx <= 1'b0;	
	end
	else begin
		tmp0_Rs232_Rx <= s1_Rs232_Rx;
		tmp1_Rs232_Rx <= tmp0_Rs232_Rx;	
	end
	
	assign nedege = !tmp0_Rs232_Rx & tmp1_Rs232_Rx;
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		bps_DR <= 16'd324;
	else begin
		case(baud_set)
			0:bps_DR <= 16'd324;
			1:bps_DR <= 16'd162;
			2:bps_DR <= 16'd80;
			3:bps_DR <= 16'd53;
			4:bps_DR <= 16'd26;
			default:bps_DR <= 16'd324;			
		endcase
	end
	
	//counter
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		div_cnt <= 16'd0;
	else if(uart_state)begin
		if(div_cnt == bps_DR)
			div_cnt <= 16'd0;
		else
			div_cnt <= div_cnt + 1'b1;
	end
	else
		div_cnt <= 16'd0;
		
	// bps_clk gen
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		bps_clk <= 1'b0;
	else if(div_cnt == 16'd1)
		bps_clk <= 1'b1;
	else
		bps_clk <= 1'b0;
	
	//bps counter
	always@(posedge clk or negedge rst_n)
	if(!rst_n)	
		bps_cnt <= 8'd0;
	else if(bps_cnt == 8'd159 | (bps_cnt == 8'd12 && (START_BIT > 2)))
		bps_cnt <= 8'd0;
	else if(bps_clk)
		bps_cnt <= bps_cnt + 1'b1;
	else
		bps_cnt <= bps_cnt;

	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		rx_done <= 1'b0;
	else if(bps_cnt == 8'd159)
		rx_done <= 1'b1;
	else
		rx_done <= 1'b0;
		
//	always@(posedge clk or negedge rst_n)
//	if(!rst_n)
//		data_byte <= 8'd0;
//	else if(bps_cnt == 8'd159)
//		data_byte <= tmp_data_byte;
//	else
//		data_byte <= data_byte;
		
		
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		data_byte <= 8'd0;
	else if(bps_cnt == 8'd159)begin
		data_byte[0] <= r_data_byte[0][2];
		data_byte[1] <= r_data_byte[1][2];
		data_byte[2] <= r_data_byte[2][2];
		data_byte[3] <= r_data_byte[3][2];
		data_byte[4] <= r_data_byte[4][2];
		data_byte[5] <= r_data_byte[5][2];
		data_byte[6] <= r_data_byte[6][2];
		data_byte[7] <= r_data_byte[7][2];
	end	
		
	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		START_BIT <= 3'd0;
		r_data_byte[0] <= 3'd0;
		r_data_byte[1] <= 3'd0;
		r_data_byte[2] <= 3'd0;
		r_data_byte[3] <= 3'd0;
		r_data_byte[4] <= 3'd0;
		r_data_byte[5] <= 3'd0;
		r_data_byte[6] <= 3'd0;
		r_data_byte[7] <= 3'd0;
		STOP_BIT <= 3'd0;
	end
	else if(bps_clk)begin
		case(bps_cnt)
			0:begin
					START_BIT <= 3'd0;
					r_data_byte[0] <= 3'd0;
					r_data_byte[1] <= 3'd0;
					r_data_byte[2] <= 3'd0;
					r_data_byte[3] <= 3'd0;
					r_data_byte[4] <= 3'd0;
					r_data_byte[5] <= 3'd0;
					r_data_byte[6] <= 3'd0;
					r_data_byte[7] <= 3'd0;
					STOP_BIT <= 3'd0;			
				end
			6,7,8,9,10,11:START_BIT <= START_BIT + s1_Rs232_Rx;
			22,23,24,25,26,27:r_data_byte[0] <= r_data_byte[0] + s1_Rs232_Rx;
			38,39,40,41,42,43:r_data_byte[1] <= r_data_byte[1] + s1_Rs232_Rx;
			54,55,56,57,58,59:r_data_byte[2] <= r_data_byte[2] + s1_Rs232_Rx;
			70,71,72,73,74,75:r_data_byte[3] <= r_data_byte[3] + s1_Rs232_Rx;
			86,87,88,89,90,91:r_data_byte[4] <= r_data_byte[4] + s1_Rs232_Rx;
			102,103,104,105,106,107:r_data_byte[5] <= r_data_byte[5] + s1_Rs232_Rx;
			118,119,120,121,122,123:r_data_byte[6] <= r_data_byte[6] + s1_Rs232_Rx;
			134,135,136,137,138,139:r_data_byte[7] <= r_data_byte[7] + s1_Rs232_Rx;
			150,151,152,153,154,155:STOP_BIT <= STOP_BIT + s1_Rs232_Rx;
			default:
				begin
					START_BIT <= START_BIT;
					r_data_byte[0] <= r_data_byte[0];
					r_data_byte[1] <= r_data_byte[1];
					r_data_byte[2] <= r_data_byte[2];
					r_data_byte[3] <= r_data_byte[3];
					r_data_byte[4] <= r_data_byte[4];
					r_data_byte[5] <= r_data_byte[5];
					r_data_byte[6] <= r_data_byte[6];
					r_data_byte[7] <= r_data_byte[7];
					STOP_BIT <= STOP_BIT;						
				end
		endcase
	end
	
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		uart_state <= 1'b0;
	else if(nedege)
		uart_state <= 1'b1;
	else if(rx_done || (bps_cnt == 8'd12 && (START_BIT > 2)))
		uart_state <= 1'b0;
	else
		uart_state <= uart_state;	

  /* always@(posedge clk or negedge rst_n)
	if(!rst_n)
	    data<=0;
		else if(data_byte==49||data_byte==50||data_byte==51||data_byte==52)
		data<=data_byte-48;
		else
		data<=0;
		
	 always@(*)
		case(data_byte)
		'd49 :data='b001;
		'd50 :data='b010;
		'd51 :data='b011;
		'd52 :data='b100;
		default: data='b000;
		endcase
*/


 always@(posedge clk or negedge rst_n)
 if(!rst_n)
 data_byter<=0;
 else
 data_byter<=data_byte;
	
	
		
 always@(*)
		case(data_byter)
		'd49 :data='b0001;
		'd50 :data='b0010;
		'd51 :data='b0100;
		'd52 :data='b1000;
		default: data='b0000;
		endcase
endmodule
