`default_nettype none

module comb_comp #(
	parameter integer numChannels=16,
	parameter integer inputBitwidth=8,
	parameter integer thresholdBitwidth=8,
	parameter integer sym_bitwidth=2,
	parameter logic [sym_bitwidth-1:0] sym_table [(2**sym_bitwidth)-1:0] = '{2'b10, 2'b11, 2'b01, 2'b00},
	parameter logic signed [sym_bitwidth+1-1:0] sym_thrsh_table [(2**sym_bitwidth)-2:0] = '{2, 0, -2}
) (
	input wire logic signed [inputBitwidth-1:0] codes [numChannels-1:0],
	input wire logic signed [thresholdBitwidth-1:0] slice_levels [2:0],

	output logic signed [(2**sym_bitwidth-1)-1:0] sym_out [numChannels-1:0]
);
    logic [(2**sym_bitwidth)-2:0] therm_enc_slicer_outputs [numChannels-1:0];

	// I am not sure how this synthesizes vs explicitly having three thresholds and a thermometer decoder

	genvar gc;
	generate
		for(gc=0; gc<numChannels; gc=gc+1) begin
			always_comb begin

				therm_enc_slicer_outputs[gc][0] = (codes[gc] > slice_levels[0]) ? 1 : 0;
				therm_enc_slicer_outputs[gc][1] = (codes[gc] > slice_levels[1]) ? 1 : 0;
				therm_enc_slicer_outputs[gc][2] = (codes[gc] > slice_levels[2]) ? 1 : 0;


				unique case (therm_enc_slicer_outputs[gc])
					3'b000: sym_out[gc] = -3;
					3'b001: sym_out[gc] = -1;
					3'b011: sym_out[gc] = 1;
					3'b111: sym_out[gc] = 3;
					default: begin
						sym_out[gc] = 0;
						$display("Exception!");
						$display("therm_enc_slicer_outputs[%d] = %b", gc, therm_enc_slicer_outputs[gc]);
						$display("codes[%d] = %d", gc, codes[gc]);
					end
				endcase
			end
		end
	endgenerate


endmodule : comb_comp
`default_nettype wire