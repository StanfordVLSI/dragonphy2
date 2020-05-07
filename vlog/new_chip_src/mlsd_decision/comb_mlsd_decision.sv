module comb_mlsd_decision #(
	parameter integer seqLength=4,
	parameter integer codeBitwidth=10,
	parameter integer shiftWidth=4,
	parameter integer numChannels=16,	
	parameter integer bufferDepth=3,
	parameter integer centerBuffer=1,
	parameter integer nbit=1,
	parameter integer cbit=1
) (
	input wire logic signed [codeBitwidth-1:0] flat_codes [numChannels*bufferDepth-1:0],
	input wire logic signed [codeBitwidth-1:0] est_seq [2**nbit-1:0][numChannels-1:0][seqLength-1:0],

	input wire logic [shiftWidth-1:0] shift_index [numChannels-1:0],

	output logic [nbit-1:0] predict_bits [numChannels-1:0]
);

localparam cursor_pos_offset = centerBuffer*numChannels;

wire logic signed [codeBitwidth-1:0] act_seq [numChannels-1:0][seqLength-1:0];
wire logic signed [codeBitwidth-1:0] error_energ   [2**nbit-1:0][numChannels-1:0];

genvar gi, gj;
generate
	for(gi=0; gi < numChannels; gi=gi+1) begin
		assign act_seq[gi] = flat_codes[cursor_pos_offset + gi + cbit +: seqLength];
		for(gj=0; gj<2**nbit; gj=gj+1) begin
			comb_eucl_dist #(
				.inWidth(codeBitwidth),
				.outWidth(codeBitwidth),
				.shiftWidth(shiftWidth),
				.seqLength(seqLength)
			) ecld_i (
				.est_seq (est_seq[gj][gi]),
				.code_seq(act_seq[gi]),
				.shift_index(shift_index[gi]),
				.distance(error_energ[gj][gi])
			);
		end
		integer ii;
		always_comb begin
			predict_bits[gi] = 0;
			for(ii=1; ii<2**nbit; ii=ii+1) begin
				//Compare and set the smallest error energy as the predicted bit
				predict_bits[gi] = error_energ[ii][gi] < error_energ[predict_bits[gi]][gi] ? ii : predict_bits[gi];
			end
		end

		//assign predict_bits[gi] = error_energ[1][gi] < error_energ[0][gi];
	end	
endgenerate


endmodule : comb_mlsd_decision

