`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:52:39 10/24/2018 
// Design Name: 
// Module Name:    hongwai_TOP 
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
module hongwai_TOP(
			input 				clk				,
		    input 				rst_n			,
		    input 				rs232_rx		,
			
			output		reg		fever			,
			
			output 	[3:0]  		thousand 	   ,
	        output 	[3:0]  		hundreds 	   ,
	        output 	[3:0]  		tens     	   ,
	        output 	[3:0]  		ones     	   
			
			


    );
	wire    [15:0]      hongwai_data   ;
	wire    		    rx_done        ;
	wire   		        clk_bps	       ;
	wire    		    cnt_start	   ;
	wire    [7:0]       rx_data_byte   ;
	
	wire	[7:0]		data_reg		;
	
	assign 	data_reg = {thousand,hundreds};
	
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			fever <= 0;
		else if(data_reg >= 8'h30)
			fever <= 1;
		else
			fever <= 0;
	end
	
	
	
	
	UART_rx uart_inst(
            .clk			(clk		),
		    .rst_n			(rst_n	),
		    .rs232_rx		(rs232_rx),
		    .bps_clk 		(clk_bps),
		    .rx_done 		(rx_done),         //一个字符接收完毕信号
		    .cnt_start      (cnt_start),          //波特率产生使能信号
		    .rx_data_byte   (rx_data_byte)
				
);


	b_bcd bcd_inst(
            .binary   (hongwai_data),
			.thousand (thousand),
			.hundreds (hundreds),
			.tens     (tens    ),
			.ones     (ones    )
    );
	
	
	seqdeta seqdeta_inst(
               .clk			  (clk	),
			   .rst_n		  (rst_n),
			   .rx_done		  (rx_done),
			   .rx_data_byte   (rx_data_byte),
			   .hongwai_data   (hongwai_data)
	);
	
	
	bps_clk  bps_clk_inst(
                .clk       (clk  ),
				.rst_n     (rst_n),
				.cnt_start (cnt_start),
				.clk_bps   (clk_bps)
    );
	
	



endmodule
