module comb_potential_codes_gen #(
	parameter integer seqLength=4,
	parameter integer estDepth=11,
	parameter integer estBitwidth=10,
	parameter integer codeBitwidth=8,
	parameter integer numChannels=16,
	parameter integer nbit=1,
	parameter integer cbit=1,
	parameter integer bufferDepth=3,
	parameter integer centerBuffer=1
) (
	input wire logic flat_bits [numChannels*bufferDepth-1:0],
	input wire logic signed [estBitwidth-1:0] channel_est [numChannels-1:0][estDepth-1:0],
	input wire logic signed [estBitwidth-1:0] precalc_seq_vals [2**nbit-1:0][numChannels-1:0][seqLength-1:0],

	output logic signed [codeBitwidth-1:0] est_seq_out [2**nbit-1:0][numChannels-1:0][seqLength-1:0]
);

localparam integer cursor_pos_offset = centerBuffer*numChannels;

//wire logic bshift_flat_bits [seqLength-1:0][numChannels-1:0][estDepth-1-nbit:0];
//wire logic signed [estBitwidth-1:0] bshift_channel_est [seqLength-1:0][numChannels-1:0][estDepth-1-nbit:0];
wire logic signed [codeBitwidth-1:0] est_seq[seqLength-1:0][numChannels-1:0][2**nbit-1:0];
wire logic signed [codeBitwidth-1:0] partial_est_seq[seqLength-1:0][numChannels-1:0];

genvar gi, gj;
generate
    for(gj=0; gj < numChannels; gj=gj+1) begin
    	if(seqLength > nbit-cbit) begin
    		//Start at the Center Bit
	    	for(gi=cbit; gi<nbit; gi=gi+1 ) begin
	    	    wire logic bshift_flat_bits [estDepth-2-gi:0];
	    	    wire logic signed [estBitwidth-1:0] bshift_channel_est[estDepth-2-gi:0];

				assign bshift_flat_bits[estDepth-2-gi:0] = flat_bits[cursor_pos_offset-1 + gj -: estDepth-1-gi];
				assign bshift_channel_est[estDepth-2-gi:0] = channel_est[gj][estDepth-1:gi+1];
				comb_partial_code_gen #(
					.partial_est_depth(estDepth-1-gi), 
					.estBitwidth(estBitwidth),
					.outBitwidth(codeBitwidth)
				) pcg_i (
					.bits            (bshift_flat_bits),
					.channel_est (bshift_channel_est),
					//Remove Center Bit Shift from the indexing here
					.partial_est_code(partial_est_seq[gi-cbit][gj])
				);
			end
			for(gi=nbit; gi < seqLength+cbit; gi=gi+1) begin
				//Extend by center bit to account for the shift
				wire logic bshift_flat_bits [estDepth-1-nbit:0];
	    	    wire logic signed [estBitwidth-1:0] bshift_channel_est[estDepth-1-nbit:0];

				assign bshift_flat_bits[estDepth-2-gi:0] 			   = flat_bits[cursor_pos_offset-1+gj    -: estDepth-1-gi];
				assign bshift_flat_bits[estDepth-1-nbit:estDepth-1-gi] = flat_bits[cursor_pos_offset+nbit+gj +: gi-nbit+1];

				assign bshift_channel_est[(gi-nbit):0] = channel_est[gj][(gi-nbit):0];
				assign bshift_channel_est[estDepth-1-nbit:(gi-nbit)+1] = channel_est[gj][estDepth-1:gi+1];
				comb_partial_code_gen #(
					.partial_est_depth(estDepth-nbit), 
					.estBitwidth(estBitwidth),
					.outBitwidth(codeBitwidth)
				) pcg_i (
					.bits            (bshift_flat_bits),
					.channel_est (bshift_channel_est),
					//Same logic as before
					.partial_est_code(partial_est_seq[gi-cbit][gj])
				);
			end
			for(gi=0; gi < seqLength; gi=gi+1) begin
				always_comb begin
					integer ii;
					for(ii=0; ii<2**nbit; ii=ii+1) begin
		            	est_seq_out[ii][gj][gi] = partial_est_seq[gi][gj] + precalc_seq_vals[ii][gj][gi];
		        	end
		    	end
			end
		end
		if(seqLength <= nbit-cbit) begin
			for(gi=cbit; gi<seqLength+cbit; gi=gi+1 ) begin
	    	    wire logic bshift_flat_bits [estDepth-2-gi:0];
	    	    wire logic signed [estBitwidth-1:0] bshift_channel_est[estDepth-2-gi:0];

				assign bshift_flat_bits[estDepth-2-gi:0] = flat_bits[cursor_pos_offset-1 + gj -: estDepth-1-gi];
				assign bshift_channel_est[estDepth-2-gi:0] = channel_est[gj][estDepth-1:gi+1];
				comb_partial_code_gen #(
					.partial_est_depth(estDepth-1-gi), 
					.estBitwidth(estBitwidth),
					.outBitwidth(codeBitwidth)
				) pcg_i (
					.bits            (bshift_flat_bits),
					.channel_est (bshift_channel_est),
					.partial_est_code(partial_est_seq[gi-cbit][gj])
				);
			end
			for(gi=0; gi < seqLength; gi=gi+1) begin
				always_comb begin
					integer ii;
					for(ii=0; ii<2**nbit; ii=ii+1) begin
		            	est_seq_out[ii][gj][gi] = partial_est_seq[gi][gj] + precalc_seq_vals[ii][gj][gi];
		        	end
		    	end
			end
		end
    end
endgenerate

endmodule : comb_potential_codes_gen
