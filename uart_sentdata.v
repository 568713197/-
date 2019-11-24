`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:40:00 05/02/2017 
// Design Name: 
// Module Name:    uart_sentdata 
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

module uart_sentdata(
							 input clk,
							 input rst_n,
							 input [7:0]tx_data,
							 input tx_enable,
							 input bps_sig,
							 output reg tx,
							 output reg tx_done
    );
    
    reg [3:0]stata;
    
    always@(posedge clk or negedge rst_n)
    begin
       if(!rst_n)
       begin
          stata <= 4'd0;
          tx <= 1'b1;
          tx_done <= 1'b0;
       end
       else 
       begin
          case(stata)
          0: if(tx_enable & bps_sig)
             begin
                stata <= stata + 1'b1;
                tx <= 1'b0;
             end
             else
             begin
                stata <= stata;
                tx <= 1'b1;
             end
           1,2,3,4,5,6,7,8: if(bps_sig)
                            begin
                               tx <= tx_data[stata - 1'b1];
                               stata <= stata + 1'b1;
                            end
                            else
                            begin
                               stata <= stata;
                               tx <= tx;
                            end
           9,10: if(bps_sig)
                 begin
                    stata <= stata + 1'b1;
                    tx <= 1'b1;
                 end
           11: begin
                  stata <= stata + 1'b1;
                  tx_done <= 1'b1;
               end
           12: begin
                  stata <= 1'b0;
                  tx_done <= 1'b0;
               end
           endcase
       end
    end

endmodule
