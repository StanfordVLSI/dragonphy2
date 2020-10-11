module dsp_backend (
	input logic signed [constant_gpack::code_precision-1:0]   codes [constant_gpack::channel_width-1:0],

	input logic clk,
	input logic rstb,

	output logic signed [ffe_gpack::output_precision-1:0] estimated_bits_q [constant_gpack::channel_width-1:0],
	output logic [mlsd_gpack::bit_length-1:0] checked_bits [constant_gpack::channel_width-1:0],

	dsp_debug_intf.dsp dsp_dbg_intf_i
);
	localparam integer ffe_code_numPastBuffers     = dsp_pack::ffe_code_numPb; //$ceil((ffe_gpack::length-1)*1.0/(constant_gpack::channel_width));
	localparam integer ffe_code_numFutureBuffers   = 0;

	localparam integer mlsd_bit_numPastBuffers    = dsp_pack::mlsd_bit_numPb; //$ceil((mlsd_gpack::estimate_depth-1)*1.0/constant_gpack::channel_width);
	localparam integer mlsd_bit_numFutureBuffers  = dsp_pack::mlsd_bit_numFb; //$ceil((mlsd_gpack::length-1)*1.0/constant_gpack::channel_width);
	localparam integer mlsd_bit_centerBuffer      = mlsd_bit_numPastBuffers;


	localparam integer mlsd_code_numPastBuffers   = dsp_pack::mlsd_code_numPb; //$ceil((mlsd_gpack::length-1)*1.0/constant_gpack::channel_width);
	localparam integer mlsd_code_numFutureBuffers = 0;
	localparam integer mlsd_code_centerBuffer     = 0;

	localparam integer ffe_pipeline_depth         = 3;
	localparam integer ffe_code_pipeline_depth    = ffe_code_numPastBuffers + ffe_code_numFutureBuffers + 1;
	localparam integer cmp_pipeline_depth         = mlsd_bit_numPastBuffers + mlsd_bit_numFutureBuffers + 1;
	localparam integer code_pipeline_depth        = ffe_code_pipeline_depth + ffe_pipeline_depth + cmp_pipeline_depth + 4;
	localparam integer mlsd_code_pipeline_depth   = mlsd_code_numPastBuffers + mlsd_code_numFutureBuffers + 1;

	localparam integer ffe_code_start             = 0;
	localparam integer mlsd_code_start 			  = ffe_pipeline_depth + ffe_code_pipeline_depth + (cmp_pipeline_depth-mlsd_code_pipeline_depth);

    localparam integer pb_buffer_depth            = 5;
	//Connecting Wires
	wire logic [constant_gpack::code_precision-1:0] ucodes_buffer  [constant_gpack::channel_width-1:0][code_pipeline_depth-1:0];

	wire logic 					  cmp_out_buffer [constant_gpack::channel_width-1:0][cmp_pipeline_depth-1:0];
	wire logic [mlsd_gpack::bit_length-1:0] pb_buffer      [constant_gpack::channel_width-1:0][pb_buffer_depth-1:0];
	
    logic signed [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0];
    logic signed [mlsd_gpack::estimate_precision-1:0]    channel_est [constant_gpack::channel_width-1:0][mlsd_gpack::estimate_depth-1:0];
    logic signed [cmp_gpack::thresh_precision-1:0] thresh [constant_gpack::channel_width-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic [mlsd_gpack::shift_precision-1:0] mlsd_shift [constant_gpack::channel_width-1:0]; 
    logic disable_product [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];


    always_comb begin
    	integer ii, jj;
    	for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
                thresh[ii]     <= dsp_dbg_intf_i.thresh[ii];
                ffe_shift[ii]  <= dsp_dbg_intf_i.ffe_shift[ii];
                mlsd_shift[ii] <= dsp_dbg_intf_i.mlsd_shift[ii];

                for(jj=0; jj<mlsd_gpack::estimate_depth; jj=jj+1) begin
                    channel_est[ii][jj] <= dsp_dbg_intf_i.channel_est[ii][jj];
                end

                for(jj=0; jj<ffe_gpack::length; jj=jj+1) begin
                	weights[jj][ii] <= dsp_dbg_intf_i.weights[ii][jj];
                	disable_product[jj][ii] <= dsp_dbg_intf_i.disable_product[jj][ii]; //Packed to Unpacked Conversion I think requires this
               	end
            end
    end


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

	wire logic        [mlsd_gpack::code_precision-1:0] flat_ucodes_ffe [constant_gpack::channel_width*ffe_code_pipeline_depth-1:0];
	flatten_buffer_slice #(
		.numChannels(constant_gpack::channel_width),
		.bitwidth   (mlsd_gpack::code_precision),
		.buff_depth (code_pipeline_depth),
		.slice_depth(ffe_code_pipeline_depth),
		.start      (ffe_code_start)
	) ffe_fb_i (
		.buffer    (ucodes_buffer),
		.flat_slice(flat_ucodes_ffe)
	);
	wire logic signed [mlsd_gpack::code_precision-1:0] flat_codes_ffe  [constant_gpack::channel_width*ffe_code_pipeline_depth-1:0];
	generate
		for(gi=0; gi<constant_gpack::channel_width*ffe_code_pipeline_depth; gi=gi+1) begin
			assign flat_codes_ffe[gi] = $signed(flat_ucodes_ffe[gi]);
		end
	endgenerate


	wire logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];

	comb_ffe #(
		.codeBitwidth(ffe_gpack::input_precision),
		.weightBitwidth(ffe_gpack::weight_precision),
		.resultBitwidth(ffe_gpack::output_precision),
		.shiftBitwidth(ffe_gpack::shift_precision),
		.ffeDepth(ffe_gpack::length),
		.numChannels(constant_gpack::channel_width),
		.numBuffers    (ffe_code_pipeline_depth),
        .t0_buff (1)
	) cffe_i (
		.weights       (weights),
		.flat_codes    (flat_codes_ffe),
		.disable_product(disable_product),
		.shift_index   (ffe_shift),
		.estimated_bits(estimated_bits)
	);

	generate
		if(ffe_pipeline_depth > 0) begin
			wire logic [ffe_gpack::output_precision-1:0] estimated_ubits [constant_gpack::channel_width-1:0];
			wire logic [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][ffe_pipeline_depth-1:0];
			buffer #(
				.numChannels(constant_gpack::channel_width),
				.bitwidth   (ffe_gpack::output_precision),
				.depth      (ffe_pipeline_depth)
			) ffe_reg_i (
				.in (estimated_ubits),
				.clk(clk),
				.rstb(rstb),
				.buffer(estimated_bits_buffer)
			);
			for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
				assign estimated_bits_q[gi] = $signed(estimated_bits_buffer[gi][ffe_pipeline_depth-1]);
				assign estimated_ubits[gi] = $unsigned(estimated_bits[gi]);
			end


		end else begin
			for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
				assign estimated_bits_q[gi] = estimated_bits[gi];
			end
		end
	endgenerate

	wire logic cmp_out [constant_gpack::channel_width-1:0];

	comb_comp #(
		.numChannels(cmp_gpack::width),
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

	wire logic 	flat_bits 	[constant_gpack::channel_width*cmp_pipeline_depth-1:0];
	flatten_buffer #(
		.numChannels(constant_gpack::channel_width),
		.bitwidth   (1),
		.depth      (cmp_pipeline_depth)
	) fb_i (
		.buffer(cmp_out_buffer),
		.flat_buffer(flat_bits)
	);

	logic signed [mlsd_gpack::code_precision-1:0] est_seq [2**mlsd_gpack::bit_length-1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];
    logic signed [mlsd_gpack::code_precision-1:0] est_seq_0 [2**mlsd_gpack::bit_length-1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];
    logic signed [mlsd_gpack::code_precision-1:0] est_seq_1 [2**mlsd_gpack::bit_length-1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];
    logic signed [mlsd_gpack::code_precision-1:0] est_seq_2 [2**mlsd_gpack::bit_length-1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];
    logic signed [mlsd_gpack::code_precision-1:0] est_seq_3 [2**mlsd_gpack::bit_length-1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];

	logic signed [mlsd_gpack::code_precision-1:0] precalc_seq_vals [2**mlsd_gpack::bit_length-1:0][constant_gpack::channel_width-1:0][mlsd_gpack::length-1:0];

	seq_val_gen #(
		.nbit(mlsd_gpack::bit_length),
		.cbit(mlsd_gpack::est_center)
	) seq_gen_i (
		.channel_est(channel_est),
		.precalc_seq_vals(precalc_seq_vals)
	);

	comb_potential_codes_gen #(
		.seqLength   (mlsd_gpack::length),
		.estDepth    (mlsd_gpack::estimate_depth),
		.estBitwidth (mlsd_gpack::estimate_precision),
		.codeBitwidth(mlsd_gpack::code_precision),
		.numChannels (mlsd_gpack::width),
		.nbit(mlsd_gpack::bit_length),
		.cbit(mlsd_gpack::est_center),
		.bufferDepth (cmp_pipeline_depth),
		.centerBuffer(mlsd_bit_centerBuffer)
	) comb_pt_cg_i (
		.flat_bits  (flat_bits),
		.channel_est(channel_est),
		.precalc_seq_vals(precalc_seq_vals),

		.est_seq_out(est_seq)
	);


   always @(posedge clk) begin
        est_seq_0 <= est_seq;
        est_seq_1 <= est_seq_0 ;
        est_seq_2 <= est_seq_1 ;
        est_seq_3 <= est_seq_2 ;
    end



	wire logic   	  [mlsd_gpack::code_precision-1:0] flat_ucodes_mlsd [mlsd_gpack::width*mlsd_code_pipeline_depth-1:0];
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

	wire logic signed [mlsd_gpack::code_precision-1:0] flat_codes_mlsd  [mlsd_gpack::width*mlsd_code_pipeline_depth-1:0];
	generate
		for(gi=0;gi<mlsd_gpack::width*mlsd_code_pipeline_depth; gi=gi+1) begin
			assign flat_codes_mlsd[gi] = $signed(flat_ucodes_mlsd[gi]);
		end
	endgenerate

	wire logic [mlsd_gpack::bit_length-1:0] predict_bits [mlsd_gpack::width-1:0];
	comb_mlsd_decision #(
		.seqLength(mlsd_gpack::length),
		.codeBitwidth(mlsd_gpack::code_precision),
		.shiftWidth  (mlsd_gpack::shift_precision),
		.numChannels(constant_gpack::channel_width),
		.bufferDepth (mlsd_code_pipeline_depth),
		.centerBuffer(mlsd_code_centerBuffer),
		.nbit(mlsd_gpack::bit_length),
		.cbit(mlsd_gpack::est_center)
	) comb_mlsd_dec_i (
		.flat_codes  (flat_codes_mlsd),
		.est_seq     (est_seq_3),
		.shift_index (mlsd_shift),
		.predict_bits(predict_bits)
	);

	buffer #(
		.numChannels(mlsd_gpack::width),
		.bitwidth   (mlsd_gpack::bit_length),
		.depth      (pb_buffer_depth)
	) pb_buff_i (
		.in(predict_bits),
		.clk   (clk),
		.rstb  (rstb),
		.buffer(pb_buffer)
	);
	generate
		for(gi=0; gi<mlsd_gpack::width; gi=gi+1) begin
			assign checked_bits[gi] = pb_buffer[gi][pb_buffer_depth-1];
		end
	endgenerate

endmodule : dsp_backend
