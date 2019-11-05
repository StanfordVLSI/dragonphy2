module comb_potential_codes_gen #(
	parameter integer seqLength=4,
	parameter integer estDepth=11,
	parameter integer estBitwidth=10,
	parameter integer codeBitwidth=8,
	parameter integer numChannels=16,
	parameter integer bufferDepth=3,
	parameter integer centerBuffer=1
) (
	input wire logic flat_bits [numChannels*bufferDepth-1:0],
	
	input wire logic signed [estBitwidth-1:0] channel_est [numChannels-1:0][estDepth-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic signed [codeBitwidth-1:0] est_seq_out [1:0][numChannels-1:0][seqLength-1:0]
);

localparam cursor_pos_offset = centerBuffer*numChannels;

wire logic bshift_flat_bits [seqLength-1:0][numChannels-1:0][estDepth-2:0];
wire logic signed [estBitwidth-1:0] bshift_channel_est [seqLength-1:0][numChannels-1:0][estDepth-2:0];
wire logic signed [codeBitwidth-1:0] est_seq[seqLength-1:0][numChannels-1:0][1:0];
wire logic signed [codeBitwidth-1:0] partial_est_seq[seqLength-1:0][numChannels-1:0];

genvar gi, gj;
generate
    for(gj=0; gj < numChannels; gj=gj+1) begin
		assign bshift_flat_bits[0][gj][estDepth-2:0] = flat_bits[cursor_pos_offset-1 + gj -: estDepth-1];
		assign bshift_channel_est[0][gj][estDepth-2:0] = channel_est[gj][estDepth-1:1];
		for(gi=1; gi < seqLength; gi=gi+1) begin
			assign bshift_flat_bits[gi][gj][estDepth-gi-2:0] = flat_bits[cursor_pos_offset-1+gj -: estDepth-gi-1];
			assign bshift_flat_bits[gi][gj][estDepth-2:estDepth-gi-1] = flat_bits[cursor_pos_offset+1+gj +: gi];
			assign bshift_channel_est[gi][gj][(gi-1):0] = channel_est[gj][(gi-1):0];
			assign bshift_channel_est[gi][gj][estDepth-2:gi] = channel_est[gj][estDepth-1:gi+1];
		end

		for(gi=0; gi < seqLength; gi=gi+1) begin
			partial_code_gen #(
				.partial_est_depth(estDepth-1), 
				.estBitwidth(estBitwidth),
				.outBitwidth(codeBitwidth)
			) pcg_i (
				.bits            (bshift_flat_bits[gi][gj]),
				.new_channel_est (bshift_channel_est[gi][gj]),
				.clk             (clk),
				.rstb            (rstb),
				.partial_est_code(partial_est_seq[gi][gj])
			);
            assign est_seq_out[0][gj][gi] = partial_est_seq[gi][gj] - channel_est[gj][gi];
            assign est_seq_out[1][gj][gi] = partial_est_seq[gi][gj] + channel_est[gj][gi];
		end
    end
    
endgenerate

endmodule : potential_codes_gen
