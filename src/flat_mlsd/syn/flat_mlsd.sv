module flat_mlsd #(
	parameter integer numChannels= 32,	
	parameter integer codeBitwidth = 8,
	parameter integer estBitwidth  = 8,
	parameter integer estDepth     = 11,
	parameter integer seqLength    = 5
) (
	input wire logic signed [codeBitwidth-1:0] codes [numChannels-1:0],
	input wire logic signed [estBitwidth-1:0] channel_est [numChannels-1:0][estDepth-1:0],
	input wire logic estimate_bits [numChannels-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic predict_bits [numChannels-1:0]
);
	localparam integer numPastBuffers  = $ceil(real'(estDepth-1)*1.0/numChannels);
	localparam integer numFutureBuffers = $ceil(real'(seqLength-1)*1.0/numChannels);

	localparam integer bufferDepth   = numPastBuffers + numFutureBuffers + 1;
	localparam integer centerBuffer  = numPastBuffers;

	//Connecting Wires
	wire logic   [codeBitwidth-1:0]  ucodes		[numChannels-1:0];
	wire logic   [codeBitwidth-1:0] uflat_codes [numChannels*bufferDepth-1:0];

	wire logic signed [codeBitwidth-1:0] flat_codes [numChannels*bufferDepth-1:0];
	wire logic 							 flat_bits 	[numChannels*bufferDepth-1:0];
    logic next_predict_bits [numChannels-1:0];

	logic signed [codeBitwidth-1:0] est_seq [1:0][numChannels-1:0][seqLength-1:0];


	genvar gi;
	generate
		for(gi=0; gi<numChannels; gi=gi+1) begin
			assign ucodes[gi] = $unsigned(codes[gi]);
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

	flat_buffer #(
		.numChannels (numChannels),
		.bitwidth    (1),
		.depth       (bufferDepth)
	) bit_fb_i (
		.in      (estimate_bits),
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
		.centerBuffer(centerBuffer)
	) comb_pt_cg_i (
		.flat_bits  (flat_bits),
		.channel_est(channel_est),
		.clk        (clk),
		.rstb       (rstb),
		.est_seq_out(est_seq)
	);

	comb_mlsd_decision #(
		.seqLength(seqLength),
		.codeBitwidth(codeBitwidth),
		.numChannels(numChannels),
		.bufferDepth (bufferDepth),
		.centerBuffer(centerBuffer)
	) comb_mlsd_dec_i (
		.flat_codes  (flat_codes),
		.est_seq     (est_seq),
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
				predict_bits[ii] <= next_predict_bits[ii];
			end
		end
	end
endmodule : flat_mlsd
