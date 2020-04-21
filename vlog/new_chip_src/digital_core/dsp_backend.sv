module dsp_backend (
	input logic signed [constant_gpack::code_precision-1:0]   codes [constant_gpack::channel_width-1:0],

	input logic clk,
	input logic rstb,

	output logic signed [constant_gpack::code_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0],
	output logic checked_bits [constant_gpack::channel_width-1:0],

	dsp_debug_intf.dsp dsp_dbg_intf_i
);
	localparam integer ffe_code_centerBuffer      = 0;
	localparam integer ffe_code_numPastBuffer     = $ceil(real'(ffe_gpack::length-1)/real'(constant_gpack::channel_width));
	localparam integer ffe_code_numFutureBuffer   = 0;

	localparam integer mlsd_bit_centerBuffer      = mlsd_bit_numPastBuffers;
	localparam integer mlsd_bit_numPastBuffers    = $ceil(real'(mlsd_gpack::estimate_depth-1)*1.0/constant_gpack::channel_width);
	localparam integer mlsd_bit_numFutureBuffers  = $ceil(real'(mlsd_gpack::length-1)*1.0/constant_gpack::channel_width);

	localparam integer mlsd_code_numPastBuffers   = $ceil(real'(mlsd_gpack::length-1)*1.0/constant_gpack::channel_width);
	localparam integer mlsd_code_numFutureBuffers = 0;
	localparam integer mlsd_code_centerBuffer     = 0;

	localparam integer ffe_pipeline_depth         = 1;
	localparam integer ffe_code_pipeline_depth    = ffe_code_numPastBuffer + ffe_code_numFutureBuffers + 1;
	localparam integer cmp_pipeline_depth         = mlsd_bit_numPastBuffers + mlsd_bit_numFutureBuffers + 1;
	localparam integer code_pipeline_depth        = ffe_code_pipeline_depth + ffe_pipeline_depth + cmp_pipeline_depth;
	localparam integer mlsd_code_pipeline_depth   = mlsd_code_numPastBuffers + mlsd_code_numFutureBuffers + 1;

	localparam integer ffe_code_start             = 0;
	localparam integer mlsd_code_start 			  = ffe_pipeline_depth + ffe_pipeline_depth + (cmp_pipeline_depth-mlsd_code_pipeline_depth);

	//Connecting Wires
	wire logic [constant_gpack::code_precision-1:0] ucodes_buffer  [constant_gpack::channel_width-1:0][code_pipeline_depth-1:0];

	wire logic 					  cmp_out_buffer [constant_gpack::channel_width-1:0][cmp_pipeline_depth-1:0];
	wire logic 					  pb_buffer      [constant_gpack::channel_width-1:0][0:0];
	
    logic [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0];
    logic [mlsd_gpack::estimate_precision-1:0]    channel_est [constant_gpack::channel_width-1:0][mlsd_gpack::estimate_depth-1:0];
    logic [cmp_gpack::thresh_precision-1:0] thresh [constant_gpack::channel_width-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic [mlsd_gpack::shift_precision-1:0] mlsd_shift [constant_gpack::channel_width-1:0]; 

    always_ff @(posedge clk or negedge rstb) begin
        integer ii, jj;
        if(!rstb) begin
            for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
                weights[ii] <= 0;
                thresh[ii]  <= 0;
                ffe_shift[ii] <= 0;
                mlsd_shift[ii] <= 0;
                for(jj=0; jj<mlsd_gpack::estimate_depth; jj=jj+1) begin
                    channel_est[ii][jj] <= 0;
                end
            end
        end else begin
            for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
                weights[ii] <= (dsp_dbg_intf_i.update_weights[ii]) ? (dsp_dbg_intf_i.new_weights[ii]) : weights[ii];
                thresh[ii]  <= (dsp_dbg_intf_i.update_thresh[ii]) ? (dsp_dbg_intf_i.new_thresh[ii]) : thresh[ii];
                ffe_shift[ii] <= (dsp_dbg_intf_i.update_ffe_shift[ii]) ? (dsp_dbg_intf_i.new_ffe_shift[ii] ): ffe_shift[ii];
                mlsd_shift[ii] <= (dsp_dbg_intf_i.update_mlsd_shift[ii]) ? (dsp_dbg_intf_i.new_mlsd_shift[ii]) : mlsd_shift[ii];
                for(jj=0; jj<mlsd_gpack::estimate_depth; jj=jj+1) begin
                    channel_est[ii][jj] <= (dsp_dbg_intf_i.update_channel_est[ii][jj]) ? (dsp_dbg_intf_i.new_channel_est[ii][jj]) : channel_est[ii][jj];
                end
            end
        end
    end

    alwa

	wire logic   [mlsd_gpack::code_precision-1:0]  ucodes		[constant_gpack::channel_width-1:0];
	genvar gi;
	generate
		for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
			assign ucodes[gi] = $unsigned(codes[gi]);
		end
	endgenerate

	buffer #(
		.numChannels (constant_gpack::channel_width),
		.bitwidth    (constant_gpack::code_precision),
		.depth       (code_pipeline_depth)
	) code_fb_i (
		.in      (ucodes),
		.clk     (clk),
		.rstb    (rstb),
		.buffer(ucodes_buffer)
	);

	flatten_buffer_slice #(
		.numChannels(constant_gpack::channel_width),
		.bitwidth   (mlsd_gpack::code_precision),
		.buff_depth (code_pipeline_depth),
		.slice_depth(ffe_code_pipeline_depth),
		.start      (ffe_code_start)
	) ffe_fb_i (
		.buffer    (ucodes_buffer)
		.flat_slice(flat_ucodes_ffe)
	);

	wire logic        [mlsd_gpack::code_precision-1:0] flat_ucodes_ffe [constant_gpack::channel_width*ffe_code_pipeline_depth-1:0];
	wire logic signed [mlsd_gpack::code_precision-1:0] flat_codes_ffe  [constant_gpack::channel_width*ffe_code_pipeline_depth-1:0];
	generate
		for(gi=0; gi<constant_gpack::channel_width*ffe_code_pipeline_depth; gi=gi+1) begin
			assign flat_codes_ffe[gi] = $signed(flat_ucodes_ffe[gi]);
		end
	endgenerate

	comb_ffe #(
		.codeBitwidth(ffe_gpack::input_precision),
		.weightBitwidth(ffe_gpack::weight_precision),
		.resultBitwidth(ffe_gpack::output_precision),
		.shiftBitwidth(ffe_gpack::shift_precision),
		.ffeDepth(ffe_gpack::length),
		.numChannels(constant_gpack::channel_width),
		.numBuffers    (ffe_code_pipeline_depth),
		.centerBuffer  (ffe_code_centerBuffer)
	) cffe_i (
		.weights       (weights),
		.flat_codes    (flat_codes_ffe),
		.shift_index   (ffe_shift),
		.estimated_bits(estimated_bits)
	);

	//If the buffer is smaller than size 1, pass through
	generate
		if(ffe_pipeline_depth > 0) begin
			wire logic [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][ffe_code_pipeline_depth-1:0];
			buffer #(
				.numChannels(constant_gpack::channel_width),
				.bitwidth   (ffe_gpack::output_precision),
				.depth      (ffe_pipeline_depth)
			) ffe_reg_i (
				.in (estimated_bits),
				.clk(clk),
				.rstb(rstb),
				.buffer(estimated_bits_buffer)
			);
			for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
				assign estimated_bits_q[gi] = estimated_bits_buffer[gi][depth-1];
			end
		end else begin
			for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
				assign estimated_bits_q[gi] = estimated_bits[gi];
			end
		end
	endgenerate


	comb_comp #(
		.numChannels(constant_gpack::channel_width),
		.inputBitwidth(cmp_gpack::input_precision),
		.thresholdBitwidth (cmp_gpack::thresh_precision),
		.confidenceBitwidth(cmp_gpack::conf_precision)
	) ccmp_i (
		.codes(estimated_bits_q),
		.thresh(thresh),
		.clk       (clk),
		.rstb      (rstb),
		.bit_out   (cmp_out)
	);

	buffer #(
		.numChannels(constant_gpack::channel_width),
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
		.numChannels(constant_gpack::channel_width),
		.bitwidth   (1),
		.depth      (cmp_pipeline_depth)
	) fb_i (
		.buffer(cmp_out_buffer),
		.flat_buffer(flat_bits)
	);

	logic signed [mlsd_gpack::code_precision-1:0] est_seq [1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];
	comb_potential_codes_gen #(
		.seqLength   (mlsd_gpack::length),
		.estDepth    (mlsd_gpack::estimate_depth),
		.estBitwidth (mlsd_gpack::estimate_precision),
		.codeBitwidth(mlsd_gpack::code_precision),
		.numChannels (mlsd_gpack::width),
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
		.numChannels(mlsd_gpack::width),
		.bitwidth   (mlsd_gpack::code_precision),
		.buff_depth (code_pipeline_depth),
		.slice_depth(mlsd_code_pipeline_depth),
		.start      (mlsd_code_start)
	) mlsd_fb_i (
		.buffer    (ucodes_buffer),
		.flat_slice(flat_ucodes_mlsd)
	);

	wire logic   	  [mlsd_gpack::code_precision-1:0] flat_ucodes_mlsd [mlsd_gpack::width*mlsd_code_pipeline_depth-1:0];
	wire logic signed [mlsd_gpack::code_precision-1:0] flat_codes_mlsd  [mlsd_gpack::width*mlsd_code_pipeline_depth-1:0];
	generate
		for(gi=0;gi<mlsd_gpack::width*mlsd_code_pipeline_depth; gi=gi+1) begin
			assign flat_codes_mlsd[gi] = $signed(flat_ucodes_mlsd[gi]);
		end
	endgenerate

	wire logic predict_bits [mlsd_gpack::width-1:0];
	comb_mlsd_decision #(
		.seqLength(mlsd_gpack::length),
		.codeBitwidth(mlsd_gpack::code_precision),
		.shiftWidth  (mlsd_gpack::shift_precision),
		.numChannels(constant_gpack::channel_width),
		.bufferDepth (mlsd_code_pipeline_depth),
		.centerBuffer(mlsd_code_centerBuffer)
	) comb_mlsd_dec_i (
		.flat_codes  (flat_codes_mlsd),
		.est_seq     (est_seq),
		.shift_index (mlsd_shift),
		.predict_bits(predict_bits)
	);

	buffer #(
		.numChannels(mlsd_gpack::width),
		.bitwidth   (1),
		.depth      (1)
	) pb_buff_i (
		.in(predict_bits),
		.clk   (clk),
		.rstb  (rstb),
		.buffer(pb_buffer)
	);
	generate
		for(gi=0; gi<mlsd_gpack::width; gi=gi+1) begin
			assign checked_bits[gi] = pb_buffer[gi][0:0];
		end
	endgenerate

endmodule : dsp_backend
