`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:25:36 10/13/2019 
// Design Name: 
// Module Name:    MQ_2 
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
module MQ_2(
clk,rst_n,t_led,da_in
    );
input clk;
input rst_n;
output  t_led;
input da_in;

assign t_led=(da_in==0)?1:0;
/*
always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    t_led<=0;
  else if(da_in==0)
    t_led<=1;
else if(da_in==1)
    t_led<=0;

end
*/
endmodule

