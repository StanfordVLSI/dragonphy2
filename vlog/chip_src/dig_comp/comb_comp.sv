`default_nettype none

module comb_comp #(
	parameter integer numChannels=16,
	parameter integer inputBitwidth=8,
	parameter integer thresholdBitwidth=8,
	parameter integer delay_width=4,
	parameter integer width_width=4,
	parameter integer sym_bitwidth=1,
	parameter logic [sym_bitwidth-1:0] sym_table [(2**sym_bitwidth)-1:0] = '{1'b1, 1'b0}
) (
	input wire logic signed [inputBitwidth-1:0] codes [numChannels-1:0],
	input wire logic [delay_width+width_width-1:0] codes_delay,
	input wire logic signed [thresholdBitwidth-1:0] thresh [(2**sym_bitwidth)-2:0][numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic [sym_bitwidth-1:0] sym_out [numChannels-1:0],
	output logic [delay_width+width_width-1:0] bit_out_delay
);

	assign bit_out_delay = codes_delay;

	localparam integer input_shift = inputBitwidth-thresholdBitwidth;

	wire logic signed [thresholdBitwidth-1:0]  inp_minus_thresh	[numChannels-1:0];

	// I am not sure how this synthesizes vs explicitly having three thresholds and a thermometer decoder

	genvar gc;
	generate
		for(gc=0; gc<numChannels; gc=gc+1) begin
			always_comb begin
				for(int ii = 0; ii < (2**sym_bitwidth)-1; ii += 1) begin
					sym_out[gc] = sym_table[0];
					if(codes[gc] > thresh[ii][gc]) begin
						sym_out[gc] = sym_table[ii+1];
					end
				end
			end
		end
	endgenerate


endmodule : comb_comp
`default_nettype wire