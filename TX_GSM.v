`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:37:13 05/02/2017 
// Design Name: 
// Module Name:    TX_GSM 
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
//////////////////////////////////////////////////////////////////////////////////
 module TX_GSM(
             input clk,
             input rst_n,
             input tx_done,
             input GSM_transmit_enable_start,
			 input GSM_transmit_enable_start2,
			 input GSM_transmit_enable_start3,
             output reg tx_enable,
             output reg[7:0]tx_data
          );
             
            reg [31:0]GSM_AT;//AT命令寄存器；
            reg [167:0]GSM_CSMP;//AT+CSMP=17,167,2,25，设置文本模式参数
            reg [127:0]GSM_CSCS;//AT+CSCS="UCS2"，设置为 UCS2 编码字符集 
            reg [87:0]GSM_CMGF;//AT+CMGF=1
            reg [447:0]GSM_CMGS;//AT + CMGS="phone_number"
            reg [327:0]GSM_TEXT;//message
            reg [9:0] GSM_num;
				reg neg1;
				reg neg2;
				wire neg_en;
				reg GSM_start;
				reg GSM_transmit_enable_stop;
            
            parameter TIME_ENABLE = 26'd60_000;
            reg[25:0] CNT_tx_enable;
            reg[20:0] CNT_tx_state_enable;          
            
             always@(posedge clk or negedge rst_n)
             begin
                if(!rst_n)
                   CNT_tx_enable <= 26'd0;
                else if(CNT_tx_enable == TIME_ENABLE)
                   CNT_tx_enable <= 26'd0;
                else 
                   CNT_tx_enable <= CNT_tx_enable + 1'b1;
             end
				 
				  always@(posedge clk or negedge rst_n)
				  begin
						if(!rst_n)
							 begin
								  neg1 <= 0;
								  neg2 <= 0;
							 end
						else
							 begin
								  neg1 <= (GSM_transmit_enable_start||GSM_transmit_enable_start2||GSM_transmit_enable_start3);
								  neg2 <= neg1;
							 end
				  end
				  
				  assign neg_en = (neg1 && !neg2)? 1'b1 : 1'b0;
				  
				  always@(posedge clk or negedge rst_n)
				  begin
					if(!rst_n)
						GSM_start <= 0;
					else if(neg_en)
						GSM_start <= 1;
					else if(GSM_transmit_enable_stop)
						GSM_start <= 0;
					else
						GSM_start <= GSM_start;
				  end
             
            always@(posedge clk or negedge rst_n)
             begin
                if(!rst_n)
                   CNT_tx_state_enable <= 26'd0;
                else if(CNT_tx_enable == TIME_ENABLE && GSM_start == 1'b1)
                begin    
                   if(GSM_num == 149)//&& cnt_T5s == 5400) 
                        CNT_tx_state_enable <= 26'd0;
                   else             
                     CNT_tx_state_enable <= CNT_tx_state_enable + 1'b1;
                end
                else 
                   CNT_tx_state_enable <= CNT_tx_state_enable;
             end
             
            always@(posedge clk or negedge rst_n)
             begin
                 if(!rst_n)
                     begin
                         tx_enable <= 1'b0;
                         GSM_AT <= 32'h0;//a_0d_54_41;
                         GSM_num <= 1'b0;
                         GSM_TEXT <= 1'b0;
                         GSM_transmit_enable_stop <= 1'b0;
                         GSM_CMGS <= 1'b0;
                         GSM_CSCS <= 128'h0;//a_0d_22_32_53_43_55_22_3d_53_43_53_43_2b_54_41;//换行、回车、AT+CSCS="UCS2"的倒序,16
                         GSM_CMGF <= 88'h0;//a_0d_31_3d_46_47_4d_43_2b_54_41;//换行、回车、AT+CMGF=1的倒序,11
                         GSM_CSMP <= 168'h0;//a_0d_35_32_2c_32_2c_37_36_31_2c_37_31_3d_50_4d_53_43_2b_54_41;//换行、回车、AT+CSMP=17,167,2,25  ,21
                     end
                 else if(tx_done)
                         tx_enable <= 1'b0;
								 
                 else if(GSM_start && CNT_tx_enable == TIME_ENABLE)
                     begin
                         if((GSM_num <= 3) && (CNT_tx_state_enable <= 300) && (CNT_tx_state_enable >= 100) )//AT
                             begin
                                 tx_enable <= 1'b1;
                                 tx_data <= GSM_AT;
                                 GSM_AT <= GSM_AT >> 8;
                                 GSM_num <= GSM_num + 1'b1;
                                 GSM_transmit_enable_stop <= 1'b0;
                             end
                        else if( 4 <= GSM_num && GSM_num <= 14 && 301 <= CNT_tx_state_enable && CNT_tx_state_enable <= 600)//CMGF
                            begin
                                tx_enable <= 1'b1;
                                tx_data <= GSM_CMGF;         
                                GSM_CMGF <= GSM_CMGF >> 8;
                                GSM_num <= GSM_num + 1'b1;
                                GSM_transmit_enable_stop <= 1'b0;
                            end
                        else if( 15 <= GSM_num && GSM_num <= 35 &&  601 <= CNT_tx_state_enable && CNT_tx_state_enable <= 900 )//CSMP
                            begin
                                tx_enable <= 1'b1;
                                tx_data <= GSM_CSMP;
                                GSM_CSMP <= GSM_CSMP >> 8;
                                GSM_num <= GSM_num + 1'b1;
                                GSM_transmit_enable_stop <= 1'b0;
                            end
                        else if( 36 <= GSM_num && GSM_num <= 51 && 901 <= CNT_tx_state_enable && CNT_tx_state_enable <= 1200)//CSCS
                            begin
                                tx_enable <= 1'b1;
                                tx_data <= GSM_CSCS;
                                GSM_CSCS <= GSM_CSCS >> 8;
                                GSM_num <= GSM_num + 1'b1;
                                GSM_transmit_enable_stop <= 1'b0;
                            end
                        else if( 52 <= GSM_num && GSM_num <= 107 && 1201 <= CNT_tx_state_enable && CNT_tx_state_enable <= 1600)//CMGS
                            begin
                                tx_enable <= 1'b1;
                                tx_data <= GSM_CMGS;
                                GSM_CMGS <= GSM_CMGS >> 8;
                                GSM_num <= GSM_num + 1'b1;
                                GSM_transmit_enable_stop <= 1'b0;
                            end
                        else if( 108 <= GSM_num && GSM_num <= 148 && 1601 <= CNT_tx_state_enable )//TEXT
                            begin
                                tx_enable <= 1'b1;
                                tx_data <= GSM_TEXT ;     
                                GSM_TEXT <= GSM_TEXT >> 8;
                                GSM_num <= GSM_num + 1'b1;
                                GSM_transmit_enable_stop <= 1'b0;
                            end
                        else if(GSM_num == 149)// && cnt_T5s == 5400)
                            begin
                                tx_enable <= 1'b0;
                                GSM_transmit_enable_stop <= 1'b1;
                                tx_data <= 0;
                                GSM_num <= 1'b0;
                            end
                     
						   	else
                            begin
								        tx_enable <= tx_enable;
								        tx_data <= tx_data;
								        GSM_num <= GSM_num;
								        GSM_transmit_enable_stop <= 1'b0;
								        GSM_AT <= 32'h0a_0d_54_41;
								        GSM_CSCS <= 128'h0a_0d_22_32_53_43_55_22_3d_53_43_53_43_2b_54_41;//换行、回车、AT+CSCS="UCS2"的倒序,16
								        GSM_CMGF <= 88'h0a_0d_31_3d_46_47_4d_43_2b_54_41;//换行、回车、AT+CMGF=1的倒序,11
								        GSM_CSMP <= 168'h0a_0d_35_32_2c_32_2c_37_36_31_2c_37_31_3d_50_4d_53_43_2b_54_41;//换行、回车、AT+CSMP=17,167,2,25  ,21
								       //   设置发送内容和发送到手机的手机号
									   if(GSM_transmit_enable_start==1)
								        GSM_TEXT <= 'h1a_36_30_34_37_35_30_45_36_36_46_35_36_41_43_33_35_37_46_42_38_43_32_30_30_31_45_45_36_36_37_38_36_37_46_33_35_30_30_45_34;//  msg{8'h1a,8'h06,8'h74,8'h05,8'h6E,8'hF6,8'h65,8'hCA,8'h53,8'hF7,8'h8B,8'h0C,8'hFF,8'hE1,8'h6E,8'hF2,8'h5D};//
								        else if(GSM_transmit_enable_start2==1)
										 GSM_TEXT <='h1a_30_33_31_37_42_36_30_37_30_33_32_35_42_34_44_36_30_43_38_36_36_37_38_36_45_33_37_35_33_38_37_35_37_46_33_35_30_30_45_34;
										else if(GSM_transmit_enable_start3==1)
										 GSM_TEXT <='h1a_33_35_46_34_34_31_43_36_33_42_42_35_39_30_37_36_30_33_32_35_42_34_44_36_30_43_38_36_36_37_38_36_37_46_33_35_30_30_45_34;
										else;
										GSM_CMGS <= 448'h0a_0d_22_39_33_30_30_38_33_30_30_30_33_30_30_32_33_30_30_33_33_30_30_30_33_30_30_32_33_30_30_39_33_30_30_35_33_30_30_38_33_30_30_31_33_30_30_22_3d_53_47_4d_43_2b_54_41;//联系人

                           end   //{8'h1a,8'h72,8'h65,8'h76,8'h65,8'h66,8'h20,8'h74,8'h6f,8'h67,8'h20,8'h79,8'h62,8'h61,8'h62}
                      end
                 else
                    begin
                        tx_enable <= tx_enable;
                        GSM_num <= GSM_num;
                        GSM_transmit_enable_stop <= 1'b0;
                   end
           end

endmodule
               
