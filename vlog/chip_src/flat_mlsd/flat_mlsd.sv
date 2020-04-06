module flat_mlsd #(
	parameter integer numChannels= 32,	
	parameter integer codeBitwidth = 8,
	parameter integer estBitwidth  = 8,
	parameter integer estDepth     = 11,
	parameter integer seqLength    = 5,
	parameter integer nbit=4,
	parameter integer cbit=1
) (
	input wire logic signed [codeBitwidth-1:0] codes [numChannels-1:0],
	input wire logic signed [estBitwidth-1:0] channel_est [numChannels-1:0][estDepth-1:0],
	input wire logic signed [estBitwidth-1:0] precalc_seq_vals [2**nbit-1:0][numChannels-1:0][seqLength-1:0],
	input wire logic estimate_bits [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output reg predict_bits [numChannels-1:0]
);
	localparam integer numPastBuffers  = $ceil(real'(estDepth-1)*1.0/numChannels);
	localparam integer numFutureBuffers = $ceil(real'(seqLength-1)*1.0/numChannels);

	localparam integer bufferDepth   = numPastBuffers + numFutureBuffers + 1;
	localparam integer centerBuffer  = numPastBuffers;
	localparam integer shiftWidth    = 4;
	
	//Connecting Wires
	wire logic   [codeBitwidth-1:0]  ucodes		[numChannels-1:0];
		 logic   [codeBitwidth-1:0]  ucodes_d_1 [numChannels-1:0];
	wire logic   [codeBitwidth-1:0] uflat_codes [numChannels*bufferDepth-1:0];
		 logic estimate_bits_d_1 [numChannels-1:0];

	wire logic signed [codeBitwidth-1:0] flat_codes [numChannels*bufferDepth-1:0];
	wire logic 							 flat_bits 	[numChannels*bufferDepth-1:0];
    logic [nbit-1:0] next_predict_bits [numChannels-1:0];

	logic signed [codeBitwidth-1:0] est_seq [2**nbit-1:0][numChannels-1:0][seqLength-1:0];

	logic [shiftWidth-1:0] shift_index [numChannels-1:0];
	
	genvar gi;
	generate
		for(gi=0; gi<numChannels; gi=gi+1) begin
			assign ucodes[gi] = $unsigned(codes[gi]);
			assign shift_index[gi] = 3;
		end
		for(gi=0; gi<numChannels*bufferDepth; gi=gi+1) begin
			assign flat_codes[gi] = $signed(uflat_codes[gi]);
		end
	endgenerate



	flat_buffer #(
		.numChannels (numChannels),
		.bitwidth    (codeBitwidth),
		.depth       (bufferDepth)
	) code_fb_i (
		.in      (ucodes),
		.clk     (clk),
		.rstb    (rstb),
		.flat_out(uflat_codes)
	);

	delay_buffer #(
		.numChannels(numChannels),
		.bitwidth(1),
		.depth(1)
	) db_b_i (
		.in(estimate_bits),
		.clk(clk),
		.rstb(rstb),
		.out (estimate_bits_d_1)
	);

	flat_buffer #(
		.numChannels (numChannels),
		.bitwidth    (1),
		.depth       (bufferDepth)
	) bit_fb_i (
		.in      (estimate_bits_d_1),
		.clk     (clk),
		.rstb    (rstb),
		.flat_out(flat_bits)
	);

	comb_potential_codes_gen #(
		.seqLength   (seqLength),
		.estDepth    (estDepth),
		.estBitwidth (estBitwidth),
		.codeBitwidth(codeBitwidth),
		.numChannels (numChannels),
		.bufferDepth (bufferDepth),
		.centerBuffer(centerBuffer),
		.nbit        (nbit),
		.cbit        (cbit)
	) comb_pt_cg_i (
		.flat_bits  (flat_bits),
		.channel_est(channel_est),
		.precalc_seq_vals(precalc_seq_vals),
		.est_seq_out(est_seq)
	);

	comb_mlsd_decision #(
		.seqLength(seqLength),
		.codeBitwidth(codeBitwidth),
		.shiftWidth  (shiftWidth),
		.numChannels(numChannels),
		.bufferDepth (bufferDepth),
		.centerBuffer(centerBuffer),
		.nbit        (nbit),
		.cbit        (cbit)
	) comb_mlsd_dec_i (
		.flat_codes  (flat_codes),
		.est_seq     (est_seq),
		.shift_index (shift_index),
		.predict_bits(next_predict_bits)
	);

	integer ii;
	always_ff @(posedge clk or negedge rstb) begin
		if(~rstb) begin
			foreach(predict_bits[ii]) begin
				predict_bits[ii] <= 0;
			end
		end else begin
			foreach(predict_bits[ii]) begin
				predict_bits[ii] <= next_predict_bits[ii][0];
			end
		end
	end
endmodule : flat_mlsd
