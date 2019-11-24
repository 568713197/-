`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:34:07 10/23/2018 
// Design Name: 
// Module Name:    UART_rx 
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
module UART_rx(
            input 				clk				,
		    input 				rst_n			,
		    input 				rs232_rx		,
		    input 				bps_clk 		,
			
		    output reg  		rx_done 		,         //一个字符接收完毕信号
		    output reg  		cnt_start       ,          //波特率产生使能信号
		    output reg  [7:0]   rx_data_byte
				
);


    reg uart_rx0,uart_rx1,uart_rx2,uart_rx3;   //接收数据寄存器
	wire neg_uart_rx;                        //数据接收到下降沿
	reg [3:0]num;

	
	always@(posedge clk or negedge rst_n)
	if(!rst_n) begin
	          uart_rx0 <= 1'b0;
			  uart_rx1 <= 1'b0;
			  uart_rx2 <= 1'b0;
			  uart_rx3 <= 1'b0;
	end
	else begin
	          uart_rx0 <= rs232_rx;             //数据寄存
			  uart_rx1 <= uart_rx0;
			  uart_rx2 <= uart_rx1;
			  uart_rx3 <= uart_rx2;
	end
			  
	  assign neg_uart_rx = ~uart_rx2 & uart_rx3;        //下降沿检测
	
	  
	  always@(posedge clk or negedge rst_n)
	  if(!rst_n) begin
	         rx_done <= 1'b0;
			 cnt_start <= 0;
	  end
	  else if(neg_uart_rx) begin     //当检测到下降沿则开始波特率计数
			 cnt_start <= 1;
	  end
	  else if(num == 4'd9) begin      //接受完所有有用信号
	         rx_done <= 1'b1;             //信号接收完毕显示
			 cnt_start <= 0;           //波特率计数停止
	  end
	  else
	        rx_done <= 1'b0;

				
		
	 always@(posedge clk or negedge rst_n)
	 if(!rst_n) begin
			  num <= 4'd0;
			  rx_data_byte <= 8'd0;
	 end
	 else begin
	        if(bps_clk)begin             //检测到波特率时钟计数器开始计数并开始赋值
		       num <= num + 1'b1;
			    case(num)
		  	        4'd1 : rx_data_byte[0] <= rs232_rx;
					4'd2 : rx_data_byte[1] <= rs232_rx;
					4'd3 : rx_data_byte[2] <= rs232_rx;
					4'd4 : rx_data_byte[3] <= rs232_rx;
					4'd5 : rx_data_byte[4] <= rs232_rx;
					4'd6 : rx_data_byte[5] <= rs232_rx;
					4'd7 : rx_data_byte[6] <= rs232_rx;
					4'd8 : rx_data_byte[7] <= rs232_rx;
					default : ;
				 endcase
			   end
	         else if(num == 4'd9)
                num <= 4'd0;            
     end
	  
	  
	 


endmodule	 
