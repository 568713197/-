`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:55 10/26/2019 
// Design Name: 
// Module Name:    p3 
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
module p3(pos,sign,clk,rst_n,rx_done
    );
input clk;
input rst_n;
input sign;
input rx_done;
output reg pos;

reg sign0,sign1,sign2;
wire posr;
always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
sign0<=0;
sign1<=0;
sign2<=0;
end
else
 begin
sign0<=sign;
sign1<=sign0;
sign2<=sign1;
end

assign  posr=(~sign2)&sign1;


always@(*)
if(rx_done==1&&posr==0)
pos=1;
else
pos=posr;


endmodule
