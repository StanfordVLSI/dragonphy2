module comb_comp #(
	parameter integer numChannels=16,
	parameter integer inputBitwidth=8,
	parameter integer thresholdBitwidth=8,
	parameter integer delay_width=4,
	parameter integer width_width=4
) (
	input wire logic signed [inputBitwidth-1:0] codes [numChannels-1:0],
	input logic [delay_width+width_width-1:0] codes_delay,
	input wire logic signed [thresholdBitwidth-1:0] thresh [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output reg bit_out [numChannels-1:0],
	output logic [delay_width+width_width-1:0] bit_out_delay
);

	assign bit_out_delay = codes_delay;

	parameter integer input_shift = inputBitwidth-thresholdBitwidth;

	wire logic signed [thresholdBitwidth-1:0]  inp_minus_thresh	[numChannels-1:0];

	genvar gc;
	generate
		for(gc=0; gc<numChannels; gc=gc+1) begin
			assign bit_out[gc] 	          =  (inp_minus_thresh[gc] >= 0) ? 1'b1 : 1'b0;
			assign inp_minus_thresh[gc]   =  ((codes[gc] >>> input_shift) - thresh[gc]);
		end
	endgenerate


endmodule : comb_comp