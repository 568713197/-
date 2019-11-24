`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:41:10 05/02/2017 
// Design Name: 
// Module Name:    GSM_top 
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
module GSM_top(
						 clk,
						 rst_n,
						 GSM_transmit_enable_start,
						 GSM_transmit_enable_start2,
						 GSM_transmit_enable_start3,
						 tx
						
    );
	  
      input clk;
		input rst_n;
		input GSM_transmit_enable_start;
		input GSM_transmit_enable_start2;
		input GSM_transmit_enable_start3;
	   output tx;
		
		
		wire bps_sig;
		wire [7:0]tx_data;
		wire tx_done;
		wire tx_enable;
	 
		uart_bps U1 (
						 .clk(clk), 
						 .rst_n(rst_n), 
						 .cnt_start(tx_enable), 
						 .bps_sig(bps_sig)
						);
                
		uart_sentdata U2 (
								 .clk(clk), 
								 .rst_n(rst_n), 
								 .tx_data(tx_data), 
								 .tx_enable(tx_enable), 
								 .bps_sig(bps_sig), 
								 .tx(tx), 
								 .tx_done(tx_done)
								 );
	 
		TX_GSM U3 (
					 .clk(clk), 
					 .rst_n(rst_n), 
					 .tx_done(tx_done), 
					 .GSM_transmit_enable_start(GSM_transmit_enable_start),
                     .GSM_transmit_enable_start2(GSM_transmit_enable_start2), 	
                     .GSM_transmit_enable_start3(GSM_transmit_enable_start3), 				 
					 .tx_enable(tx_enable), 
					 .tx_data(tx_data)
					);


endmodule

