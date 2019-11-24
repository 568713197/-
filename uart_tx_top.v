module uart_tx_top(Clk,Rst_n,Rs232_Tx,led,led1,t_led,fever,o_hundreds,o_ones,o_tens,o_thousand,thousand,hundreds,tens,ones
);

	input Clk;
	input Rst_n;
	output Rs232_Tx;
  input led;//满桶报警
  input led1;//火焰报警
  input t_led;//气体报警
  input fever;//温度报警
input [3:0]	o_thousand	;
input [3:0]	o_hundreds 	;
input [3:0]	o_tens		;
input [3:0]	o_ones		; 
input [3:0]	thousand	;
input [3:0]	hundreds 	;
input [3:0]	tens		;
input [3:0]	ones		;

wire tx_done;
	wire Clk;
	wire send_en;
	wire [7:0]data_byte;
	
	uart_byte_tx uart_byte_tx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.data_byte(data_byte),
		.send_en(send_en),
		.baud_set(3'd4),
		
		.Rs232_Tx(Rs232_Tx),
		.Tx_Done(tx_done),
		.uart_state()
	);
	

tx U2(   .clk(Clk),
         .rst_n(Rst_n),
		 .data_byte(data_byte),
		 .send_en(send_en),
         .key(led),
		 .led(led1),
		 .t_led(t_led),
		 .fever(fever),
		   .o_ones(o_ones),
		   .o_tens(o_tens),
		   .o_hundreds(o_hundreds),
		   .o_thousand(o_thousand),
		   .thousand (thousand),
		   .hundreds (hundreds),
		   .tens     (tens    ),
		   .ones     (ones    ),
		   .tx_done(tx_done)
);



	

endmodule
