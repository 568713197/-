`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:08:43 10/11/2019 
// Design Name: 
// Module Name:    TOP 
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
module TOP1(clk,rst_n,rs232_tx,ultrasound_echo,ultrasound_trig,led,fever,rs232_rx,led1,do_in,t_led,da_in,tx_t,pwm_out1,pwm_out2,rx
);

input clk;
input rst_n;
output rs232_tx;//串口输出
input rs232_rx;//红外输入
input do_in;//火焰输入
input da_in;//气体输入
input rx ;//舵机输入

output ultrasound_trig;	//超声波测距模块脉冲激励信号，10us的高脉冲
input ultrasound_echo;		//超声波测距模块回响信号

output led;//满桶报警
output led1;//火焰报警
output t_led;//气体报警
output fever;//温度报警

//output [3:0] send_out;
output tx_t;//短信
output pwm_out1;//控制舵机输出
output pwm_out2;
//output send_out;

	     
wire send_en;
wire [7:0] data_byte;
wire tx_done;
wire [3:0] o_hundreds;
wire [3:0] o_thousand;
wire [3:0] o_tens;
wire [3:0] o_ones;
wire [3:0] thousand ;
wire [3:0] hundreds ;
wire [3:0] tens     ;
wire [3:0] ones     ;

Z1 U1(
      .clk(clk),
	  .rst_n(rst_n),
	  .pwm_out1(pwm_out1),
	  .pwm_out2(pwm_out2),
	  .rs232_rx(rx)
);


uart_tx_top U2(.Clk(clk),
          .Rst_n(rst_n),
         .led(led),//满桶
		 .led1(led1),//火焰
		 .t_led(t_led),//气体
		 .fever(fever),
	     .o_hundreds(o_hundreds),
		   .o_ones(o_ones),
		   .o_tens(o_tens),
		   .o_thousand(o_thousand),
		   .thousand (thousand),
		   .hundreds (hundreds),
		   .tens     (tens    ),
		   .ones     (ones    ),
		   .Rs232_Tx(rs232_tx)
);
 	

sp6 U3(    .clk(clk),
           .rst_n(rst_n),
		   .ultrasound_trig(ultrasound_trig),
		   .ultrasound_echo(ultrasound_echo),
		   .led(led),
		   .o_hundreds(o_hundreds),
		   .o_ones(o_ones),
		   .o_tens(o_tens),
		   .o_thousand(o_thousand)
	);

hongwai_TOP U4(.clk(clk),
               .rst_n(rst_n),
			   .rs232_rx(rs232_rx),
			   .fever(fever),
			   .thousand (thousand),
			   .hundreds (hundreds),
			   .tens     (tens    ),
			   .ones     (ones    )
);

GSM_top U7( .clk(clk),
            .rst_n(rst_n),
		.GSM_transmit_enable_start(led),
		.GSM_transmit_enable_start2(led1),
		.GSM_transmit_enable_start3(t_led),
		.tx(tx_t)
);

FIRE U5(.clk(clk),
        .rst_n(rst_n),
		.led(led1),
		.do_in(do_in)
);

MQ_2 U6(.clk(clk),
        .rst_n(rst_n),
		.t_led(t_led),
		.da_in(da_in)
);

									
endmodule 
