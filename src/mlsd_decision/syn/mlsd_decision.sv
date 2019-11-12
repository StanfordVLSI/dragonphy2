module mlsd_decision #(
	parameter integer seqLength=4,
	parameter integer codeBitwidth=10,
	parameter integer numChannels=16,	
	parameter integer bufferDepth=3,
	parameter integer centerBuffer=1
) (
	input wire logic signed [codeBitwidth-1:0] flat_codes [numChannels*bufferDepth-1:0],
	input wire logic signed [codeBitwidth-1:0] est_seq [1:0][numChannels-1:0][seqLength-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic predict_bits [numChannels-1:0]
);

localparam cursor_pos_offset = centerBuffer*numChannels;

wire logic signed [codeBitwidth-1:0] act_seq [numChannels-1:0][seqLength-1:0];
wire logic signed [codeBitwidth-1:0] error_energ   [1:0][numChannels-1:0];
wire logic next_predict_bits [numChannels-1:0];

genvar gi;
generate
	for(gi=0; gi < numChannels; gi=gi+1) begin
		assign act_seq[gi] = flat_codes[cursor_pos_offset + gi +: seqLength];
		eucl_dist #(
			.inWidth(codeBitwidth),
			.outWidth(codeBitwidth),
			.seqLength(seqLength)
		) zero_ecld_i (
			.est_seq (est_seq[0][gi]),
			.code_seq(act_seq[gi]),

			.clk     (clk),
			.rstb    (rstb),

			.energ   (error_energ[0][gi])
		);

		eucl_dist #(
			.inWidth(codeBitwidth),
			.outWidth(codeBitwidth),
			.seqLength(seqLength)
		) one_ecld_i (
			.est_seq (est_seq[1][gi]),
			.code_seq(act_seq[gi]),

			.clk     (clk),
			.rstb    (rstb),

			.energ   (error_energ[1][gi])
		);

		assign next_predict_bits[gi] = error_energ[1][gi] < error_energ[0][gi];

		always_ff @(posedge clk or negedge rstb) begin : proc_predict_bits
			if(~rstb) begin
				predict_bits[gi] <= 0;
			end else begin
				predict_bits[gi] <= next_predict_bits[gi];
			end
		end
	end	
endgenerate


endmodule : mlsd_decision

