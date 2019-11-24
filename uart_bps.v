`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:39:01 05/02/2017 
// Design Name: 
// Module Name:    uart_bps 
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

module uart_bps(
					 input clk,
					 input rst_n,
					 input cnt_start,
					 output bps_sig
    );

    
    reg [12:0]cnt_bps;
    
    parameter bps_t = 13'd5207;
    
    always@(posedge clk or negedge rst_n)
    begin
       if(!rst_n)
          cnt_bps <= 13'd0;
       else if(cnt_bps == bps_t)
          cnt_bps <= 13'd0;
       else if(cnt_start)
          cnt_bps <= cnt_bps + 1'b1;
       else 
          cnt_bps <= 1'b0;
    end
    
    assign bps_sig = (cnt_bps ==  13'd2604) ? 1'b1 : 1'b0;
     
endmodule
