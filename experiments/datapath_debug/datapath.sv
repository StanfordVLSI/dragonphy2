module datapath (
	input logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    input logic clk,
    input logic rstb,

    output logic signed [ffe_gpack::output_precision-1:0]   estimated_bits_out [constant_gpack::channel_width-1:0],
    output logic                                               sliced_bits_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   est_codes_out [constant_gpack::channel_width-1:0],
    output logic signed [error_gpack::est_error_precision-1:0] est_errors_out [constant_gpack::channel_width-1:0],
    output logic        [1:0] sd_flags [constant_gpack::channel_width-1:0]
);

	dsp_debug_intf dsp_dbg_intf_i;

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
		.sd_flags(sd_flags)

		.dsp_dbg_intf_i(dsp_dbg_intf_i)
	);

endmodule : datapath