`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:32:35 10/04/2019 
// Design Name: 
// Module Name:    SP66 
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
module sp6(
			input clk,	//外部输入25MHz时钟信号
			input rst_n,	//外部输入复位信号，低电平有效
			output ultrasound_trig,	//超声波测距模块脉冲激励信号，10us的高脉冲
			input ultrasound_echo,		//超声波测距模块回响信号
			output led,
			//output start,
			output [3:0]	o_thousand		 ,
			output [3:0]	o_hundreds 		,
			output [3:0]	o_tens		    ,
			output [3:0]	o_ones		  	
		);													
 
//-------------------------------------
//PLL例化
wire clk_25m;	//PLL输出25MHz时钟

wire [3:0]	thousand		 ;
wire [3:0]	hundreds 		;
wire [3:0]	tens		    ;
wire [3:0]	ones		    ;

wire [15:0] data;
//wire [15:0] in_data;
wire clk_100khz_en;	//100KHz频率的一个时钟使能信号，即每10us产生一个时钟脉冲
//wire [15:0] data_out;
	

	wire [15:0] data_in;
	assign data_in={hundreds,tens,ones,4'b0000};
	assign o_thousand=data_in[15:12];
	assign o_hundreds=data_in[11:8];
	assign o_tens=data_in[7:4];
	assign o_ones=data_in[3:0];

div uut_div(
            .clk(clk),
			.out(clk_25m),
			.rst_n(rst_n)
);
 
clkdiv_generation	uut_clkdiv_generation(
				.clk(clk_25m),		//时钟信号
				.rst_n(rst_n),	//复位信号，低电平有效
				.clk_100khz_en(clk_100khz_en)	//100KHz频率的一个时钟使能信号，即每10us产生一个时钟脉冲
			);			


wire echo_pulse_en; 
ultrasound_controller	uut_ultrasound_controller(
				.clk(clk_25m),		//时钟信号
				.rst_n(rst_n),	//复位信号，低电平有效
				.led(led),
				.data(data),//.data(in_data),
				.echo_pulse_en(echo_pulse_en),
				.clk_100khz_en(clk_100khz_en),	//100KHz频率的一个时钟使能信号，即每10us产生一个时钟脉冲
				.ultrasound_trig(ultrasound_trig),	//超声波测距模块脉冲激励信号，10us的高脉冲
				.ultrasound_echo(ultrasound_echo)	//超声波测距模块回响信号

			);
			
b_bcd uut_bcd(
            .binary   (data),
			.thousand (thousand),
			.hundreds (hundreds),
			.tens     (tens    ),
			.ones     (ones    )
    );

/*
datar uut_data(
            .clk(clk_25m),//clk
			.data_out(data_out),
			.data_in(data_in),
			.rst_n(rst_n),
			.start(start)
);



wire[15:0] echo_pulse_filter_num;	//滤波处理后的超声波测距模块回响信号高脉冲计数值
 
filter		uut_filter(
				.clk(clk),		//时钟信号
				.rst_n(rst_n),	//复位信号，低电平有效
				.echo_pulse_en(echo_pulse_en),		//超声波测距模块回响信号计数值有效信号
				.echo_pulse_num(in_data),		//以10us为单位对超声波测距模块回响信号高脉冲进行计数的最终值
				.echo_pulse_filter_num(data)	//滤波处理后的超声波测距模块回响信号高脉冲计数值
			);	*/
			


endmodule
 
/////////////////////////////////////////////////////////////////////////////
//工程硬件平台： Xilinx Spartan 6 FPGA
/////////////////////////////////////////////////////////////////////////////
module ultrasound_controller(
				input clk,		//外部输入25MHz时钟信号
				input rst_n,	//外部输入复位信号，低电平有效
				input clk_100khz_en,	//100KHz频率的一个时钟使能信号，即每10us产生一个时钟脉冲
				output ultrasound_trig,	//超声波测距模块脉冲激励信号，10us的高脉冲
				input ultrasound_echo,		//超声波测距模块回响信号
				output reg	led,
				output reg echo_pulse_en,
				output [15:0] data
			);															
						
//-------------------------------------------------
//1s定时产生逻辑
reg[16:0] timer_cnt;	//1s计数器，以100KHz（10us）为单位进行计数，计数1s需要的计数范围是0~99999
 reg[15:0] echo_pulse_num;
	//1s定时计数
always @(posedge clk or negedge rst_n)
	if(!rst_n) timer_cnt <= 17'd0;
	else if(clk_100khz_en) begin
		if(timer_cnt < 17'd99_999) timer_cnt <= timer_cnt+1'b1;
		else timer_cnt <= 17'd0;
	end
	else ;
 
assign ultrasound_trig = (timer_cnt == 17'd1) ? 1'b1:1'b0;		//10us高脉冲生成						
 
 
//-------------------------------------------------
//超声波测距模块的回响信号echo打两拍，产生上升沿和下降沿标志位
reg[1:0] ultrasound_echo_r;
 
always @(posedge clk or negedge rst_n)
	if(!rst_n) ultrasound_echo_r <= 2'b00;
	else ultrasound_echo_r <= {ultrasound_echo_r[0],ultrasound_echo};
 
wire pos_echo = ~ultrasound_echo_r[1] & ultrasound_echo_r[0];	//echo信号上升沿标志位，高电平有效一个时钟周期
wire neg_echo = ultrasound_echo_r[1] & ~ultrasound_echo_r[0];	//echo信号下降沿标志位，高电平有效一个时钟周期
 
 always @(posedge clk or negedge rst_n)
	if(!rst_n) echo_pulse_en <= 1'b0;
	else echo_pulse_en <= neg_echo; 
	
//-------------------------------------------------
//以10us为单位对超声波测距模块回响信号高脉冲进行计数
reg[15:0] echo_cnt;		//回响高脉冲计数器
 
always @(posedge clk or negedge rst_n)
	if(!rst_n) echo_cnt <= 16'd0;
	else if(pos_echo) echo_cnt <= 16'd0;	//计数清零
	else if(clk_100khz_en && ultrasound_echo_r[0]) echo_cnt <= echo_cnt+1'b1;
	else ;
	
always @(posedge clk or negedge rst_n)
	if(!rst_n) echo_pulse_num <= 16'd0;	
	else if(neg_echo) echo_pulse_num <= echo_cnt;
	
always @(posedge clk or negedge rst_n)
     if(!rst_n) led<= 'd0;	
	else if(echo_pulse_num<=40) led<=1;//&&echo_pulse_num>=250
	else
	  led<=0;
 assign data=(echo_pulse_num*443)/256;
//assign data=(echo_pulse_num*1741)>>10;   
 
endmodule

module clkdiv_generation(
				input clk,		//外部输入25MHz时钟信号
				input rst_n,	//外部输入复位信号，低电平有效
				output clk_100khz_en	//100KHz频率的一个时钟使能信号，即每10us产生一个时钟脉冲
			);															
						
//-------------------------------------------------
//时钟分频产生
reg[7:0] cnt;	//时钟分频计数器，0-249
 
	//1s定时计数
always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 8'd0;
	else if(cnt < 8'd249) cnt <= cnt+1'b1;
	else cnt <= 8'd0;
 
assign clk_100khz_en = (cnt == 8'd249) ? 1'b1:1'b0;		//每40us产生一个40ns的高脉冲				
 
endmodule

/*
module div(
				input clk,		//外部输入25MHz时钟信号
				input rst_n,	//外部输入复位信号，低电平有效
				output reg out	//100KHz频率的一个时钟使能信号，即每10us产生一个时钟脉冲
			);															
						

always @(posedge clk or negedge rst_n)
	if(!rst_n) out <= 0;
	else out<= out+1'b1;
 			
 
endmodule
 */