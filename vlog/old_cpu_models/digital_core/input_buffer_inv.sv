`default_nettype none
 

module input_buffer_inv ( 
	input wire logic inp, 
	input wire logic inm, 
	input wire logic pd, 
	output wire clk, 
	output wire clk_b
);

//synopsys translate_off

assign clk = pd ? 1'b0 : inp;
assign clk_b = pd ? 1'b0 : inm;

//synopsys translate_on

endmodule
`default_nettype wire

