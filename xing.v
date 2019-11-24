`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:09:55 10/11/2019 
// Design Name: 
// Module Name:    xing 
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
module xing(clk,rst_n,data_byte,send_en,rs232_tx,tx_done
    ); 
input clk;
input rst_n;
input [7:0] data_byte;
input  send_en;

output reg rs232_tx;
output reg tx_done;
//output 
reg uart_state;

reg bps_clk;
reg [15:0] div_cnt;
reg [3:0] bps_cnt;
reg [7:0] r_data_byte;


parameter  start_bit=1'b0;
parameter stop_bit=1'b1;
parameter bps_dr=5207;

always@(posedge clk or negedge rst_n)
if(!rst_n)
uart_state<=1'b0;
else if(send_en)
uart_state<=1'b1;
else if(tx_done)
uart_state<=0;
else
uart_state<=uart_state;

always@(posedge clk or negedge rst_n)
if(!rst_n)
r_data_byte<=8'b0;
else if(send_en)
r_data_byte<=data_byte;
else
r_data_byte<=r_data_byte;


always@(posedge clk or negedge rst_n)
if(!rst_n)
bps_clk<=0;
else if(div_cnt==1)
bps_clk<=1'b1;
else
bps_clk<=0;

always@(posedge clk or negedge rst_n)
if(!rst_n)
div_cnt<=0;
else if(uart_state) begin
if(div_cnt==bps_dr)
div_cnt<=0;
else
div_cnt<=div_cnt+1'b1;
end
else
div_cnt<=0;

always@(posedge clk or negedge rst_n)
if(!rst_n)
bps_cnt<=0;
else if(tx_done)
bps_cnt<=0;
else if(bps_clk)
bps_cnt<=bps_cnt+1'b1;
else
bps_cnt<=bps_cnt;

//tx_done   PC端发送完数据形成一个上升脉冲
always@(posedge clk or negedge rst_n)
if(!rst_n)
tx_done<=0;
else if(bps_cnt==11)
tx_done<=1'b1;
else
tx_done<=0;

always@(*)
case(bps_cnt)
4'd0 : rs232_tx<=1;
4'd1 : rs232_tx<=start_bit;
4'd2 : rs232_tx<=r_data_byte[0];
4'd3 : rs232_tx<=r_data_byte[1];
4'd4 : rs232_tx<=r_data_byte[2];
4'd5 : rs232_tx<=r_data_byte[3];
4'd6 : rs232_tx<=r_data_byte[4];
4'd7 : rs232_tx<=r_data_byte[5];
4'd8 :rs232_tx<=r_data_byte[6];
4'd9 : rs232_tx<=r_data_byte[7];
4'd10 : rs232_tx<=stop_bit;
default : rs232_tx<=1;
endcase

endmodule
