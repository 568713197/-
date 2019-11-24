`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:02:42 10/11/2019 
// Design Name: 
// Module Name:    tx 
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
module tx(clk,rst_n,key,send_en,data_byte,tx_done,fever,led,t_led,o_hundreds,o_ones,o_tens,o_thousand,thousand,hundreds,tens,ones
);
input clk;
input rst_n;
input tx_done;
input key;
input fever;
input led;
input t_led;
input [3:0]	o_thousand	;
input [3:0]	o_hundreds 	;
input [3:0]	o_tens		;
input [3:0]	o_ones		; 
input [3:0]	thousand	;
input [3:0]	hundreds 	;
input [3:0]	tens		;
input [3:0]	ones		;

output reg send_en;
output reg [7:0] data_byte;


wire st;
assign st=key|fever|led|t_led;

reg key_tmp0,key_tmp1,key_tmp2;
reg fever0,fever1,fever2;
reg led_r0,led_r1,led_r2;
reg t_led0,t_led1,t_led2;
reg [8:0] cnt1;

parameter CT=200_000;


reg [20:0] cntr;
always@(posedge clk or negedge rst_n)
if(!rst_n)
cntr<=0;
else if(cntr==CT)
cntr<=CT;
else 
cntr<=cntr+1;



reg clr;
always@(posedge clk or negedge rst_n)
if(!rst_n)
clr<=0;
else if(cntr==CT-1)
clr<=1;
else if(cnt1=='d36)
clr<=1;
else
clr<=0;

reg [3:0] cnt;
always@(posedge clk or negedge rst_n)
if(!rst_n)
cnt<=0;
else if(cnt==13&&clr==1)
cnt<='d2;
else if(clr==1)
cnt<=cnt+1'b1;


parameter
    byte1=8'h43,//C
	byte2=8'h4C,//L
	byte3=8'h53,//S
	byte4=8'h28,//(
	byte5=8'h29,//)
	byte6=8'h3B,//;
	byte7=8'h42,//B
	byte8=8'h50,//P
	byte9=8'h49,//I
	byte10=8'h2C,//,
	byte11=8'h27,//'   '
	byte12=8'h4F,//O
	
	byte14=8'hBC,
	byte15=8'hEC,//检
	byte16=8'hB2,
	byte17=8'hE2,//测
	byte18=8'hCA,
	byte19=8'hFD,//数
	byte20=8'hD1,
	byte21=8'hE6,//焰
	byte22=8'hBB,
	byte23=8'hF0,//火
	byte24=8'h20,
	byte25=8'h2E,//.
	
	byte26=8'hD3,
	byte27=8'hE0,//余
	byte28=8'hC1,
	byte29=8'hBF,//量
	byte30=8'hCE,
	byte31=8'hC2,//温
	byte32=8'hB6,
	byte33=8'hC8,//度
	byte34=8'hCD,
	byte35=8'hB0,//桶
	byte36=8'hC4,
	byte37=8'hDA,//内
	byte38=8'hCE,
	byte39=8'hB4,//未
	byte40=8'hD2,
	byte41=8'hD1,//已
	byte42=8'hB5,
	byte43=8'hBD,//到
	byte45=8'hD2,
	byte46=8'hEC,//异
	byte47=8'hB3,
	byte48=8'hA3,//常
	byte49=8'hB1,
	byte50=8'hA8,//报
	byte51=8'hBE,
	byte52=8'hAF,//警
	byte53=8'hD2,
	byte54=8'hBB,//一
	byte55=8'hC7,
	byte56=8'hD0,//切
	byte57=8'hD5,
	byte58=8'hFD,//正
	byte59=8'hB3,
	byte60=8'hA3,//常
	byte61=8'hBE,
	byte62=8'hDD,//据
	byte63=8'h3A,//：
	
	byte64=8'h63,//c
	byte65=8'h6D,//m
	byte66=8'h86,
	byte67=8'hC8,//度·

	byte13=8'h0A;//换行
	
always@(posedge clk or negedge rst_n)
if(!rst_n)
cnt1<=0;
else if (tx_done&&cntr==CT)
cnt1<=cnt1+1'b1;
else if(clr)
cnt1<=0;

	
always@(posedge clk or negedge rst_n)
if(!rst_n)
send_en<=0;
else if(clr)
send_en<=1'b1;
else if(tx_done&(cnt1<38))//30
send_en<=1'b1;
else
send_en<=0;	

always@(posedge clk or negedge rst_n)
if(!rst_n)
data_byte=0;
else 
if(cnt=='d1)
case(cnt1)
0 : data_byte=byte1;
1 : data_byte=byte2;
2 : data_byte=byte3;
3 : data_byte=byte4;
4 : data_byte='d48;
5 : data_byte=byte5;
6 : data_byte=byte6;
7 : data_byte=byte13;
default : data_byte=0;
endcase
else if(cnt=='d3)
case(cnt1)
0 : data_byte=byte8;
1 : data_byte=byte3;
2 : data_byte='d49;
3 : data_byte='d54;
4 : data_byte=byte4;
5 : data_byte='d49;
6 : data_byte=byte10;
7 : data_byte='d53;
8 : data_byte=byte10;
9 : data_byte='d53;
10 : data_byte=byte10;
11 : data_byte=byte11;
12 : data_byte=byte18;
13 : data_byte=byte19;
14 : data_byte=byte61;
15 : data_byte=byte62;
16 : data_byte=byte14;
17 : data_byte=byte15;
18 : data_byte=byte16;
19 : data_byte=byte17;
20 : data_byte=byte63;
21 : data_byte=byte11;
22 : data_byte=byte10;
23 : data_byte='d53;
24 : data_byte=byte5;
25 : data_byte=byte6;
26 : data_byte=byte13;
default : data_byte=0;
endcase
else if(cnt=='d5)
case(cnt1)
0 : data_byte=byte8;
1 : data_byte=byte3;
2 : data_byte='d49;
3 : data_byte='d54;
4 : data_byte=byte4;
5 : data_byte='d49;
6 : data_byte=byte10;
7 : data_byte='d53;
8 : data_byte=byte10;
9 : data_byte='d51;
10 : data_byte='d55;
11 : data_byte=byte10;
12 : data_byte=byte11;
13 : data_byte=byte34;
14 : data_byte=byte35;
15 : data_byte=byte36;
16 : data_byte=byte37;
17 : data_byte=byte26;
18 : data_byte=byte27;
19 : data_byte=byte28;
20 : data_byte=byte29;
21 : data_byte=byte63;
22 : data_byte=o_thousand+48;
23 : data_byte=o_hundreds+48;
24 : data_byte=byte25;
25 : data_byte=o_tens+48;
26 : data_byte=o_ones+48;
27 : data_byte=byte64;
28 : data_byte=byte65;
29 : data_byte=byte11;
30 : data_byte=byte10;
31 : data_byte='d50;
32 : data_byte=byte5;
33 : data_byte=byte6;
34 : data_byte=byte13;
default : data_byte=0;
endcase
else if(cnt=='d7)
case(cnt1)
0 : data_byte=byte8;
1 : data_byte=byte3;
2 : data_byte='d49;
3 : data_byte='d54;
4 : data_byte=byte4;
5 : data_byte='d49;
6 : data_byte=byte10;
7 : data_byte='d53;
8 : data_byte=byte10;
9 : data_byte='d54;
10 : data_byte='d57;
11 : data_byte=byte10;
12 : data_byte=byte11;
13 : data_byte=byte34;
14 : data_byte=byte35;
15 : data_byte=byte36;
16 : data_byte=byte37;
17 : data_byte=byte30;
18 : data_byte=byte31;
19 : data_byte=byte32;
20 : data_byte=byte33;
21 : data_byte=byte63;
22 : data_byte=thousand+48;
23 : data_byte=hundreds+48;
24 : data_byte=byte25;
25 : data_byte=tens+48;
26 : data_byte=ones+48;
27 : data_byte=byte32;
28 : data_byte=byte33;
29 : data_byte=byte11;
30 : data_byte=byte10;
31 : data_byte='d50;
32 : data_byte=byte5;
33 : data_byte=byte6;
34 : data_byte=byte13;
default : data_byte=0;
endcase
else if(cnt=='d9)
case(cnt1)
0 : data_byte=byte8;
1 : data_byte=byte3;
2 : data_byte='d49;
3 : data_byte='d54;
4 : data_byte=byte4;
5 : data_byte='d49;
6 : data_byte=byte10;
7 : data_byte='d53;
8 : data_byte=byte10;
9 : data_byte='d49;
10 : data_byte='d48;
11 : data_byte='d49;
12 : data_byte=byte10;
13 : data_byte=byte11;
14 : if(led) 
      data_byte=byte40;
      else
	    data_byte=byte38;
15 :  if(led) 
      data_byte=byte41;
      else 
	    data_byte=byte39;
16 : data_byte=byte14;
17 : data_byte=byte15;
18 : data_byte=byte16;
19 : data_byte=byte17;
20 : data_byte=byte42;
21 : data_byte=byte43;
22 : data_byte=byte22;
23 : data_byte=byte23;
24 : data_byte=byte20;
25 : data_byte=byte21;
26 : data_byte=byte11;
27 : data_byte=byte10;
28 :if(led) 
      data_byte='d49;
      else
	    data_byte='d50; 
29 : data_byte=byte5;
30 : data_byte=byte6;
31 : data_byte=byte13;
default : data_byte=0;
endcase
else if(cnt=='d11)
case(cnt1)
0 : data_byte=byte8;
1 : data_byte=byte3;
2 : data_byte='d49;
3 : data_byte='d54;
4 : data_byte=byte4;
5 : data_byte='d49;
6 : data_byte=byte10;
7 : data_byte='d53;
8 : data_byte=byte10;
9 : data_byte='d49;
10 : data_byte='d51;
11 : data_byte='d51;
12 : data_byte=byte10;
13 : data_byte=byte11;
14 : if(t_led) 
      data_byte=byte40;
      else
	    data_byte=byte38;
15 :  if(t_led) 
      data_byte=byte41;
      else 
	    data_byte=byte39;
16 : data_byte=byte14;
17 : data_byte=byte15;
18 : data_byte=byte16;
19 : data_byte=byte17;
20 : data_byte=byte42;
21 : data_byte=byte43;
22 : data_byte=byte1;
23 : data_byte=byte12;
24 : data_byte=byte11;
25 : data_byte=byte10;
26 :if(t_led) 
      data_byte='d49;
      else
	    data_byte='d50; 
27 : data_byte=byte5;
28 : data_byte=byte6;
29 : data_byte=byte13;
default : data_byte=0;
endcase
else if(cnt=='d13)
case(cnt1)
0 : data_byte=byte8;
1 : data_byte=byte3;
2 : data_byte='d49;
3 : data_byte='d54;
4 : data_byte=byte4;
5 : data_byte='d49;
6 : data_byte=byte10;
7 : data_byte='d53;
8 : data_byte=byte10;
9 : data_byte='d49;
10 : data_byte='d54;
11 : data_byte='d53;
12 : data_byte=byte10;
13 : data_byte=byte11;
14 : if(st) 
      data_byte=byte45;
      else
	    data_byte=byte53;
15 :  if(st) 
      data_byte=byte46;
      else 
	    data_byte=byte54;
16 : if(st) 
      data_byte=byte47;
      else
	    data_byte=byte55;
17 : if(st) 
      data_byte=byte48;
      else
	    data_byte=byte56;
18 : if(st) 
      data_byte=byte49;
      else
	    data_byte=byte57;
19 : if(st) 
      data_byte=byte50;
      else
	    data_byte=byte58;
20 : if(st) 
      data_byte=byte51;
      else
	    data_byte=byte59;
21 : if(st) 
      data_byte=byte52;
      else
	    data_byte=byte60;
22 : data_byte=byte11;
23 : data_byte=byte10;
24 :if(st) 
      data_byte='d49;
      else
	    data_byte='d50; 
25 : data_byte=byte5;
26 : data_byte=byte6;
27 : data_byte=byte13;
default : data_byte=0;
endcase
endmodule



