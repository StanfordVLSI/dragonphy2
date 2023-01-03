`default_nettype none

module comb_comp #(
	parameter integer numChannels=16,
	parameter integer inputBitwidth=8,
	parameter integer thresholdBitwidth=8,
	parameter integer delay_width=4,
	parameter integer width_width=4,
	parameter integer sym_bitwidth=2,
	parameter logic [sym_bitwidth-1:0] sym_table [(2**sym_bitwidth)-1:0] = '{2'b10, 2'b11, 2'b01, 2'b00},
	parameter logic signed [sym_bitwidth+1-1:0] sym_thrsh_table [(2**sym_bitwidth)-2:0] = '{2, 0, 2}
) (
	input wire logic signed [inputBitwidth-1:0] codes [numChannels-1:0],
	input wire logic [delay_width+width_width-1:0] codes_delay,

	input wire logic signed [inputBitwidth-1:0] bit_level,

	output logic [sym_bitwidth-1:0] sym_out [numChannels-1:0],
	output logic [delay_width+width_width-1:0] bit_out_delay
);
    logic [(2**sym_bitwidth)-2:0] therm_enc_slicer_outputs [numChannels-1:0];
	assign bit_out_delay = codes_delay;

	// I am not sure how this synthesizes vs explicitly having three thresholds and a thermometer decoder

	genvar gc;
	generate
		for(gc=0; gc<numChannels; gc=gc+1) begin
			always_comb begin
				for(int ii = 0; ii < (2**sym_bitwidth)-1; ii += 1) begin
					therm_enc_slicer_outputs[ii][gc] = (codes[gc] >  bit_level * sym_thrsh_table[ii]) ? 1 : 0;
				end

				unique case (therm_enc_slicer_outputs[gc])
					3'b000: sym_out[gc] = 2'b00;
					3'b001: sym_out[gc] = 2'b01;
					3'b011: sym_out[gc] = 2'b11;
					3'b111: sym_out[gc] = 2'b10;
				endcase
			end
		end
	endgenerate


endmodule : comb_comp
`default_nettype wire