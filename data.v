`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:15:23 10/31/2019 
// Design Name: 
// Module Name:    data 
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
module data(clk,rst_n,data_in,sign
    );
input clk;
input rst_n;
input [7:0] data_in;
output reg sign;

reg [7:0] datar0,datar1,datar2,datar3;


always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
datar0<='b0;
datar1<='b0;
datar2<='b0;
datar3<='b0;
end
else begin
datar0<=data_in;
datar1<=datar0;
datar2<=datar1;
datar3<=datar2;
end

always@(posedge clk or negedge rst_n)
if(!rst_n)
sign<=0;
else if(datar3!=data_in)
sign<=0;
else if(datar3==data_in)
sign<=1;
else;

endmodule
