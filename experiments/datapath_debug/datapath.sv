module datapath (
	input logic [constant_gpack::code_precision-1:0] unsigned_adc_codes [constant_gpack::channel_width-1:0],

	input logic [ffe_gpack::weight_precision-1:0] unsigned_weights [ffe_gpack::length-1:0],
	input logic [ffe_gpack::shift_precision-1:0]  ffe_shift,

	input logic [cmp_gpack::thresh_precision-1:0] unsighed_thresh,

	input logic [channel_gpack::est_channel_precision-1:0] unsigned_channel_est [channel_gpack::est_channel_depth-1:0],
	input logic [channel_gpack::shift_precision-1:0] channel_shift,

	input logic [$clog2(constant_gpack::channel_width)-1:0] align_pos,

    input logic clk,
    input logic rstb,

    output logic [ffe_gpack::output_precision-1:0]   unsigned_estimated_bits_out [constant_gpack::channel_width-1:0],
    output logic                                              sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic [constant_gpack::code_precision-1:0]   unsigned_est_codes_out [constant_gpack::channel_width-1:0],
    output logic [error_gpack::est_error_precision-1:0] unsigned_est_errors_out [constant_gpack::channel_width-1:0],
    output logic        [1:0] sd_flags [constant_gpack::channel_width-1:0]
);


	logic signed [constant_gpack::code_precision-1:0]   adc_codes [constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::output_precision-1:0]      estimated_bits_out [constant_gpack::channel_width-1:0];
    logic signed [constant_gpack::code_precision-1:0]   est_codes_out [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] est_errors_out [constant_gpack::channel_width-1:0];

	logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0],
	logic signed [cmp_gpack::thresh_precision-1:0] thresh,
	logic signed [channel_gpack::est_channel_precision-1:0] channel_est [channel_gpack::est_channel_depth-1:0],


    integer ii, jj;
    always_comb begin
    	thresh = $unsigned(unsigned_thresh);

    	for(ii=0; ii<ffe_gpack::length; ii=ii+1) begin
    		weights[ii] 		   = $unsigned(unsigned_weights[ii]);
    	end

    	for(ii=0; ii<channel_gpack::est_channel_depth; ii=ii+1) begin
            channel_est[ii] 	   = $unsigned(unsigned_channel_est[ii]);
    	end

        for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            adc_codes[ii]          = $unsigned(unsigned_adc_codes[ii]);
            estimated_bits_out[ii] = $unsigned(unsigned_estimated_bits_out[ii]);
            est_codes_out[ii]      = $unsigned(unsigned_est_codes_out[ii]);
            est_errors_out[ii]     = $unsigned(unsigned_est_errors_out[ii]);

        end

        dsp_dbg_intf_i.align_pos = align_pos;

        for(ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
        	dsp_dbg_intf_i.thresh[ii] = thresh;
        	dsp_dbg_intf_i.ffe_shift[ii]  = ffe_shift;
        	dsp_dbg_intf_i.channel_shift[ii] = channel_shift;
	        for(jj=0; jj<ffe_gpack::length; jj=jj+1) begin
	    		dsp_dbg_intf_i.weights[ii][jj] 	   = weights[jj];
	    	end

	    	for(jj=0; jj<channel_gpack::est_channel_depth; jj=jj+1) begin
	            dsp_dbg_intf_i.channel_est[ii][jj] = channel_est[jj];
	    	end
        end

        for(jj=0; jj<ffe_gpack::length; jj=jj+1) begin
    		dsp_dbg_intf_i.disable_product[jj] = 16'b000000000000;
    	end
    end

	dsp_debug_intf dsp_dbg_intf_i();

	datapath_core #(
		.ffe_pipeline_depth(0),
		.channel_pipeline_depth(0),
		.error_output_pipeline_depth(0),
		.sliding_detector_output_pipeline_depth(0)
	) dc_i (
		.adc_codes(adc_codes),
		.clk(clk),
		.rstb(rstb),
		.estimated_bits_out(estimated_bits_out),
		.sliced_bits_out(sliced_bits_out),
		.est_codes_out(est_codes_out),
		.est_errors_out(est_errors_out),
		.sd_flags(sd_flags),

		.dsp_dbg_intf_i(dsp_dbg_intf_i)
	);

endmodule : datapath
