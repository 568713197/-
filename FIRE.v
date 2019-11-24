`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:39:37 10/12/2019 
// Design Name: 
// Module Name:    FIRE 
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
module FIRE(clk,rst_n,led,do_in
    );

input clk;
input rst_n;
input do_in;
output led;

assign led=(do_in==0)?1:0;

/*
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
led<=0;
else if(do_in==0)
led<=1;
else
led<=0;
end
*/
endmodule
