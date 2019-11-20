module comb_mlsd_decision #(
	parameter integer seqLength=4,
	parameter integer codeBitwidth=10,
	parameter integer shiftWidth=4,
	parameter integer numChannels=16,	
	parameter integer bufferDepth=3,
	parameter integer centerBuffer=1
) (
	input wire logic signed [codeBitwidth-1:0] flat_codes [numChannels*bufferDepth-1:0],
	input wire logic signed [codeBitwidth-1:0] est_seq [1:0][numChannels-1:0][seqLength-1:0],

	input wire logic [shiftWidth-1:0] shift_index [numChannels-1:0],

	output logic predict_bits [numChannels-1:0]
);

localparam cursor_pos_offset = centerBuffer*numChannels;

wire logic signed [codeBitwidth-1:0] act_seq [numChannels-1:0][seqLength-1:0];
wire logic signed [codeBitwidth-1:0] error_energ   [1:0][numChannels-1:0];

genvar gi;
generate
	for(gi=0; gi < numChannels; gi=gi+1) begin
		assign act_seq[gi] = flat_codes[cursor_pos_offset + gi +: seqLength];
		comb_eucl_dist #(
			.inWidth(codeBitwidth),
			.outWidth(codeBitwidth),
			.shiftWidth(shiftWidth),
			.seqLength(seqLength)
		) zero_ecld_i (
			.est_seq (est_seq[0][gi]),
			.code_seq(act_seq[gi]),
			.shift_index(shift_index[gi]),
			.energ   (error_energ[0][gi])
		);

		comb_eucl_dist #(
			.inWidth(codeBitwidth),
			.outWidth(codeBitwidth),
			.shiftWidth(shiftWidth),
			.seqLength(seqLength)
		) one_ecld_i (
			.est_seq (est_seq[1][gi]),
			.code_seq(act_seq[gi]),
			.shift_index(shift_index[gi]),
			.energ   (error_energ[1][gi])
		);

		assign predict_bits[gi] = error_energ[1][gi] < error_energ[0][gi];
	end	
endgenerate


endmodule : comb_mlsd_decision

