`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:36:44 10/23/2018 
// Design Name: 
// Module Name:    seqdeta 
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
module seqdeta(
               input 		       clk			  ,
			   input 		       rst_n		  ,
			   input 		       rx_done		  ,
			   input  [7:0]        rx_data_byte   ,
			   output reg [15:0]   hongwai_data
	);
		
	reg [3:0] state;
	
	parameter s0=4'b0000, s1=4'b0001, s2=4'b0010, s3=4'b0011,
				 s4=4'b0100, s5=4'b0101, s6=4'b0110;
	
	
     always @(posedge clk or negedge rst_n)  //状态检测
     if(!rst_n) 
            state <= s0;
     else if(rx_done==1'b1)  //一个字符信号接收完毕
     begin
           case(state)
               s0 : if(rx_data_byte==8'h5a)
                       state <= s1;
			        else 
			           state <= s0;
               s1 : if(rx_data_byte==8'h5a)
                       state <= s2;
			        else
			           state <= s0;
               s2 : if(rx_data_byte==8'h45)
                       state <= s3;
			        else
			           state <= s0;
               s3 : if(rx_data_byte==8'h04)
                       state <= s4;
			        else
			           state <= s0;
               s4 : begin
						hongwai_data [15:8] <= rx_data_byte;
					    state <= s5;
					end
			   
               s5 : begin
						hongwai_data [7:0] <= rx_data_byte;
						state <= s6;
					end

               s6 : if(rx_data_byte==8'h09)
                       state <= s0;
			        else
			           state <= s6;
               default :state <= s0; 			 
             endcase
          end
  
  


endmodule