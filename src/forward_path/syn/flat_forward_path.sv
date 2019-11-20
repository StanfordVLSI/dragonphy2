module flat_forward_path #(
	parameter integer numChannels  = 32,	
	parameter integer codeBitwidth = 8,
	parameter integer 
	parameter integer estBitwidth  = 8,
	parameter integer estDepth     = 11,
	parameter integer seqLength    = 5
) (
	input wire logic signed [codeBitwidth-1:0] codes [numChannels-1:0],
	input wire logic signed [estBitwidth-1:0] channel_est [numChannels-1:0][estDepth-1:0],

	input wire logic clk,
	input wire logic rstb,

	output logic checked_bits [numChannels-1:0]
);
	localparam integer ffe_code_centerBuffer      = 0;
	localparam integer ffe_code_numPastBuffer     = $ceil(real'(ffe_gpack::length-1)/real'(numChannels));
	localparam integer ffe_code_numFutureBuffer   = 0;

	localparam integer mlsd_bit_centerBuffer      = mlsd_bit_numPastBuffers;
	localparam integer mlsd_bit_numPastBuffers    = $ceil(real'(estDepth-1)*1.0/numChannels);
	localparam integer mlsd_bit_numFutureBuffers  = $ceil(real'(seqLength-1)*1.0/numChannels);

	localparam integer mlsd_code_numPastBuffers   = $ceil(real'(seqLength-1)*1.0/numChannels);
	localparam integer mlsd_code_numFutureBuffers = 0;
	localparam integer mlsd_code_centerBuffer     = 0;

	localparam integer ffe_pipeline_depth         = 1;
	localparam integer ffe_code_pipeline_depth    = ffe_code_numPastBuffer + ffe_code_numFutureBuffers + 1 
	localparam integer cmp_pipeline_depth         = mlsd_bit_numPastBuffers + mlsd_bit_numFutureBuffers + 1;
	localparam integer code_pipeline_depth        = ffe_code_pipeline_depth + ffe_pipeline_depth + cmp_pipeline_depth;
	localparam integer mlsd_code_pipeline_depth   = mlsd_code_numPastBuffers + mlsd_code_numFutureBuffers + 1;

	localparam integer ffe_code_start             = 0;
	localparam integer mlsd_code_start 			  = ffe_pipeline_depth + ffe_pipeline_depth + (cmp_pipeline_depth-mlsd_code_pipeline_depth);



	//Connecting Wires

	wire logic [codeBitwidth-1:0] ucodes_buffer  [numChannels-1:0][code_pipeline_depth-1:0];
	wire logic 					  cmp_out_buffer [numChannels-1:0][cmp_pipeline_depth-1:0];
	wire logic 					  pb_buffer      [numChannels-1:0][0:0];
	



	wire logic   [codeBitwidth-1:0]  ucodes		[numChannels-1:0];
	genvar gi;
	generate
		for(gi=0; gi<numChannels; gi=gi+1) begin
			assign ucodes[gi] = $unsigned(codes[gi]);
		end
	endgenerate

	buffer #(
		.numChannels (numChannels),
		.bitwidth    (codeBitwidth),
		.depth       (code_pipeline_depth)
	) code_fb_i (
		.in      (ucodes),
		.clk     (clk),
		.rstb    (rstb),
		.buffer(ucodes_buffer)
	);

	flatten_buffer_slice #(
		.numChannels(numChannels),
		.bitwidth   (codeBitwidth),
		.buff_depth (code_pipeline_depth),
		.slice_depth(ffe_code_pipeline_depth),
		.start      (ffe_code_start)
	) ffe_fb_i (
		.buffer    (ucodes_buffer)
		.flat_slice(flat_ucodes_ffe)
	);

	wire logic        [codeBitwidth-1:0] flat_ucodes_ffe [numChannels*ffe_code_pipeline_depth-1:0];
	wire logic signed [codeBitwidth-1:0] flat_codes_ffe  [numChannels*ffe_code_pipeline_depth-1:0];
	generate
		for(gi=0; gi<numChannels*ffe_code_pipeline_depth; gi=gi+1) begin
			assign flat_codes_ffe[gi] = $signed(flat_ucodes_ffe[gi]);
		end
	endgenerate

	comb_ffe #(
		.codeBitwidth(ffe_gpack::input_precision),
		.weightBitwidth(ffe_gpack::weight_precision),
		.resultBitwidth(ffe_gpack::output_precision),
		.shiftBitwidth(ffe_gpack::shift_precision),
		.ffeDepth(ffe_gpack::length),
		.numChannels(numChannels),
		.numBuffers    (ffe_code_pipeline_depth),
		.centerBuffer  (ffe_code_centerBuffer)
	) cffe_i (
		.weights       (weights),
		.flat_codes    (flat_codes_ffe),
		.shift_index   (shift_index),
		.estimated_bits(estimated_bits)
	);

	//If the buffer is smaller than size 1, pass through
	generate
		if(ffe_pipeline_depth > 0) begin
			wire logic [ffe_gpack::output_precision-1:0] estimated_bits_buffer [numChannels-1:0][ffe_code_pipeline_depth-1:0];
			buffer #(
				.numChannels(numChannels),
				.bitwidth   (ffe_gpack::output_precision),
				.depth      (ffe_pipeline_depth)
			) ffe_reg_i (
				.in (estimated_bits),
				.clk(clk),
				.rstb(rstb),
				.buffer(estimated_bits_buffer)
			);
			for(gi=0; gi<numChannels; gi=gi+1) begin
				assign estimated_bits_q[gi] = estimated_bits_buffer[gi][depth-1];
			end
		end else begin
			for(gi=0; gi<numChannels; gi=gi+1) begin
				assign estimated_bits_q[gi] = estimated_bits[gi];
			end
		end
	endgenerate


	comb_comp #(
		.numChannels(numChannels),
		.inputBitwidth(cmp_gpack::input_precision),
		.thresholdBitwidth (cmp_gpack::thresh_precision),
		.confidenceBitwidth(cmp_gpack::conf_precision)
	) ccmp_i (
		.codes(estimated_bits_q),
		.new_thresh(new_thresh),
		.clk       (clk),
		.rstb      (rstb),
		.bit_out   (cmp_out)
	);

	buffer #(
		.numChannels(numChannels),
		.bitwidth   (1),
		.depth      (cmp_pipeline_depth)
	) cmp_reg_i (
		.in(cmp_out),
		.clk   (clk),
		.rstb  (rstb),
		.buffer(cmp_out_buffer)
	);

	wire logic 	flat_bits 	[numChannels*cmp_pipeline_depth-1:0];
	flatten_buffer #(
		.numChannels(numChannels),
		.bitwidth   (1),
		.depth      (cmp_pipeline_depth)
	) fb_i (
		.buffer(cmp_out_buffer),
		.flat_buffer(flat_bits)
	);

	logic signed [codeBitwidth-1:0] est_seq [1:0][numChannels-1:0][seqLength-1:0];
	comb_potential_codes_gen #(
		.seqLength   (seqLength),
		.estDepth    (estDepth),
		.estBitwidth (estBitwidth),
		.codeBitwidth(codeBitwidth),
		.numChannels (numChannels),
		.bufferDepth (cmp_pipeline_depth),
		.centerBuffer(mlsd_bit_centerBuffer)
	) comb_pt_cg_i (
		.flat_bits  (flat_bits),
		.channel_est(channel_est),
		.clk        (clk),
		.rstb       (rstb),
		.est_seq_out(est_seq)
	);

	flatten_buffer_slice #(
		.numChannels(numChannels),
		.bitwidth   (codeBitwidth),
		.buff_depth (code_pipeline_depth),
		.slice_depth(mlsd_code_pipeline_depth),
		.start      (mlsd_code_start)
	) mlsd_fb_i (
		.buffer    (ucodes_buffer),
		.flat_slice(flat_ucodes_mlsd)
	);

	wire logic   	  [codeBitwidth-1:0] flat_ucodes_mlsd [numChannels*mlsd_code_pipeline_depth-1:0];
	wire logic signed [codeBitwidth-1:0] flat_codes_mlsd  [numChannels*mlsd_code_pipeline_depth-1:0];
	generate
		for(gi=0;gi<numChannels*mlsd_code_pipeline_depth; gi=gi+1) begin
			assign flat_codes_mlsd[gi] = $signed(flat_ucodes_mlsd[gi]);
		end
	endgenerate

	wire logic predict_bits [numChannels-1:0];
	comb_mlsd_decision #(
		.seqLength(seqLength),
		.codeBitwidth(codeBitwidth),
		.shiftWidth  (shiftWidth),
		.numChannels(numChannels),
		.bufferDepth (mlsd_code_pipeline_depth),
		.centerBuffer(mlsd_code_centerBuffer)
	) comb_mlsd_dec_i (
		.flat_codes  (flat_codes_mlsd),
		.est_seq     (est_seq),
		.shift_index (shift_index),
		.predict_bits(predict_bits)
	);

	buffer #(
		.numChannels(numChannels),
		.bitwidth   (1),
		.depth      (1)
	) pb_buff_i (
		.in(predict_bits),
		.clk   (clk),
		.rstb  (rstb),
		.buffer(pb_buffer)
	);
	generate
		for(gi=0; gi<numChannels; gi=gi+1) begin
				assign checked_bits[gi] = pb_buffer[gi][0:0];
		end
	endgenerate

endmodule : flat_mlsd
