module input_buffer (
	input wire logic inp,
	input wire logic inn,
	input wire logic en,
	input wire logic in_aux,
	input wire logic sel_in,
	input wire logic bypass_div,
	input wire logic [2:0] ndiv,
	input wire logic en_meas,

	output wire logic out,
	output wire logic out_meas
);
	assign out = inp;
endmodule