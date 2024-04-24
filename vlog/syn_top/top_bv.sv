`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

package channel_gpack;
    localparam integer width = 16;
    localparam integer est_channel_depth = 30;
    localparam integer est_channel_precision = 11;
    localparam integer est_code_precision = 8;
    localparam integer shift_precision = 4;
endpackage
package cmp_gpack;
    localparam integer width = 16;
    localparam integer input_precision = 10;
    localparam integer conf_precision = 8;
    localparam integer thresh_precision = 10;
endpackage
package constant_gpack;
    localparam integer channel_width = 16;
    localparam integer code_precision = 8;
    localparam integer ffe_length = 16;
    localparam integer ffe_weight_precision = 10;
    localparam integer ffe_shift = 8;
    localparam integer mlsd_shift = 8;
    localparam integer sym_bitwidth = 2;
    localparam integer stage1_ffe_pipeline_depth = 1;
    localparam integer stage2_chan_pipeline_depth = 2;
    localparam integer stage2_err_out_pipeline_depth = 1;
    localparam integer stage3_sld_dtct_out_pipeline_depth = 1;
endpackage
package detector_gpack;
    localparam integer width = 16;
    localparam integer seq_length = 3;
    localparam integer est_error_precision = 9;
    localparam integer est_channel_precision = 11;
    localparam integer branch_bitwidth = 2;
    localparam integer num_of_trellis_patterns = 4;
    localparam integer trellis_pattern_depth = 4;
endpackage
package error_gpack;
    localparam integer width = 16;
    localparam integer est_error_precision = 9;
    localparam integer ener_bitwidth = 15;
endpackage
package ffe_gpack;
    localparam integer length = 16;
    localparam integer width = 16;
    localparam integer input_precision = 8;
    localparam integer output_precision = 10;
    localparam integer weight_precision = 10;
    localparam integer shift_precision = 5;
endpackage
package const_pack;

    // parameters related to circuit configuration
    localparam integer Nti = 16;
    localparam integer Nadc = 8;        // ADC bits
    localparam integer Nti_rep = 2;     // # of Replicas
    localparam integer Nout = 4;        // number of PI output clock phases
    localparam integer Nv2t = 5;        // number of V2T current control
    localparam integer Nrange = 4;      // params used in adc unfolding ops
    localparam integer Nbrc = 4;        // number of branches per each PI clock
    localparam integer N_mem_addr = 10; // number of bits in SRAM address
    localparam integer Nbias = 4;
    localparam integer Npi = 9;         // PI control bits / UI
    localparam integer Nblender = 4;    // number of phaes blender control bits in a PI
    localparam integer Nunit_pi = 32;   // number of delay units in each delay chain of a PI
    localparam integer Nmax = 3;
    localparam integer Ndepth = 20;
    localparam integer Ndiv = 4;        // samples are accumulated for 2**Ndiv cycles
    localparam integer Ncdr_avg = 128;
    localparam integer prop_width = 8;
    localparam integer intg_width = 8;
    localparam integer phase_est_shift = 8;
    localparam integer N_mem_width = 18;
    localparam integer N_mem_tiles  = 2;
    localparam integer Nprbs = 32;      // length of LFSR used in PRBS checker
endpackage

module signed_buffer #(
    parameter integer numChannels = 16,
    parameter integer bitwidth    = 8,
    parameter integer depth       = 5,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic signed [bitwidth-1:0] in [numChannels-1:0],
    input logic [delay_width+width_width-1:0] in_delay,


    input logic clk,
    input logic rstb,
    (*retiming_backward = 1 *) output logic signed  [bitwidth-1:0] buffer [numChannels-1:0][depth:0],
    output logic [delay_width+width_width-1:0] buffer_delay [depth:0]


);

// synthesis translate_off
always_comb begin
    for(int ii =0; ii < depth + 1; ii = ii + 1) begin
        buffer_delay[ii] = (ii << width_width) + in_delay;
    end
end
// synthesis translate_on

genvar gi;

generate
    for(gi=0; gi<numChannels;gi=gi+1) begin
        always @(posedge clk or negedge rstb) begin
            if(~rstb) begin
                 for(int ii=1;ii<depth+1; ii=ii+1) begin
                    buffer[gi][ii] <= 0;
                 end
            end else begin
                if(depth > 0) begin
                    for(int ii=0; ii<depth; ii=ii+1) begin
                        buffer[gi][depth-ii] <= buffer[gi][depth-1-ii];
                    end
                end
            end
        end
        always_comb begin
            if(~rstb) begin
                buffer[gi][0] = 0;
            end else begin
                buffer[gi][0] = in[gi];
            end
        end
    end
endgenerate
endmodule : signed_buffer

module buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth       = 1,
	parameter integer delay_width = 4,
	parameter integer width_width = 4
) (
	input  logic [bitwidth-1:0] in [numChannels-1:0],
	input  logic [delay_width+width_width-1:0] in_delay,
	input  logic clk,
	input  logic rstb,
	(*retiming_backward = 1 *) output logic [bitwidth-1:0] buffer [numChannels-1:0][depth:0],
	output logic [delay_width+width_width-1:0] buffer_delay [depth:0]
);

genvar gi;

// synthesis translate_off
always_comb begin
	for(int ii =0; ii < depth + 1; ii = ii + 1) begin
		buffer_delay[ii] = (ii << width_width) + in_delay;
	end
end
// synthesis translate_on

generate
	for(gi=0; gi<numChannels;gi=gi+1) begin

		always @(posedge clk or negedge rstb) begin
			if(~rstb) begin
				 for(int ii=1;ii<depth+1; ii=ii+1) begin
				 	buffer[gi][ii] <= 0;
				 end
			end else begin
				if(depth > 0) begin
					for(int ii=0; ii<depth; ii=ii+1) begin
						buffer[gi][depth-ii] <= buffer[gi][depth-1-ii];
					end
				end
			end
		end

		always_comb begin
			if(~rstb) begin
				buffer[gi][0] = 0;
			end else begin
				buffer[gi][0] = in[gi];
			end
		end
	end
endgenerate

endmodule : buffer

module signed_flatten_buffer #(
    parameter integer numChannels = 16,
    parameter integer bitwidth    = 8,
    parameter integer depth       = 5,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    buffer,
    buffer_delay,
    flat_buffer,
    flat_buffer_delay
);


        input wire logic signed [bitwidth-1:0] buffer [numChannels-1:0][depth:0];
        output logic signed [bitwidth-1:0] flat_buffer [numChannels*(1+depth)-1:0];
        input logic [delay_width+width_width-1:0] buffer_delay[depth:0];
        output logic [delay_width+width_width-1:0] flat_buffer_delay;
// synthesis translate_off
assign flat_buffer_delay = buffer_delay[0];
// synthesis translate_on

genvar gi, gj;
generate 
    for(gj=0; gj<numChannels; gj=gj+1) begin
        for(gi=0; gi<depth+1; gi=gi+1) begin
            assign flat_buffer[(depth - gi)*numChannels + gj] = buffer[gj][gi];
        end
    end
endgenerate

endmodule : signed_flatten_buffer

module signed_flatten_buffer_slice #(
    parameter integer numChannels = 16,
    parameter integer bitwidth    = 8,
    parameter integer buff_depth  = 5,
    parameter integer slice_depth = 3,
    parameter integer start       = 0,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    buffer,
    buffer_delay,
    flat_slice,
    flat_slice_delay
);



    input wire logic signed [bitwidth-1:0] buffer [numChannels-1:0][buff_depth:0];
    output     logic signed [bitwidth-1:0] flat_slice [numChannels*(1+slice_depth)-1:0];

    logic signed [bitwidth-1:0] buffer_slice [numChannels-1:0][slice_depth:0];

    input logic [delay_width+width_width-1:0] buffer_delay[buff_depth:0];

    output logic [delay_width+width_width-1:0] flat_slice_delay;

    logic [delay_width+width_width-1:0] buffer_slice_delay [slice_depth:0];



genvar gi, gj;
generate
    for(gi=0; gi < slice_depth+1; gi=gi+1) begin
        for(gj=0; gj<numChannels; gj=gj+1) begin
            assign buffer_slice[gj][gi] = buffer[gj][gi + start]; 
        end
        assign buffer_slice_delay[gi] = buffer_delay[gi+start];

    end
endgenerate

signed_flatten_buffer #(
    .numChannels(numChannels),
    .bitwidth   (bitwidth),
    .depth      (slice_depth)
) flat_buff_i (
    .buffer     (buffer_slice),
    .buffer_delay ( buffer_slice_delay),
    .flat_buffer(flat_slice),
    .flat_buffer_delay(flat_slice_delay)
);

endmodule : signed_flatten_buffer_slice

module signed_data_aligner #(
    parameter integer width=16,
    parameter integer depth=2,
    parameter integer bitwidth=8,
    parameter integer delay_width=4,
    parameter integer width_width=4
) (
    input logic signed  [bitwidth-1:0] data_segment [width*depth-1:0],
    input logic [delay_width + width_width-1:0] data_segment_delay,

    input logic [$clog2(width*(depth-1))-1:0] align_pos,
    output logic signed [bitwidth-1:0] aligned_data [width-1:0],
    output logic [delay_width + width_width-1:0] aligned_data_delay


);

    assign aligned_data_delay = data_segment_delay + (width*(depth-1)- align_pos);


    integer ii;
    always_comb begin
        for(ii=0; ii<width; ii = ii + 1) begin
            aligned_data[ii] = data_segment[ii+align_pos];
        end
    end

endmodule : signed_data_aligner


module comb_ffe #(
	parameter integer codeBitwidth=8,
	parameter integer weightBitwidth=11,
	parameter integer resultBitwidth=8,
	parameter integer shiftBitwidth=5,
	parameter integer ffeDepth=5,
	parameter integer numChannels=16,
	parameter integer numBuffers=2,
	parameter integer t0_buff=1
) (
	input wire logic signed [weightBitwidth-1:0] weights [ffeDepth-1:0][numChannels-1:0],
	input wire logic signed [codeBitwidth-1:0] flat_codes [numBuffers*numChannels-1:0],
	input wire logic [shiftBitwidth-1:0] shift_index [numChannels-1:0],


	output logic signed [resultBitwidth-1:0] estimated_bits [numChannels-1:0]

);

localparam productBitwidth   = codeBitwidth + weightBitwidth;
localparam sumBitwidth	 = $clog2(ffeDepth) + productBitwidth;
localparam idx = t0_buff * numChannels;

logic signed [sumBitwidth-1:0] result [numChannels-1:0];


genvar gi;
generate
	for(gi=0; gi<numChannels; gi=gi+1) begin
		always_comb begin 
			integer ii;
			result[gi] = 0;
			for(ii=0; ii<ffeDepth; ii=ii+1) begin
				result[gi] = result[gi] + weights[ii][gi] * flat_codes[idx - ii + gi];
			end
			estimated_bits[gi] = (result[gi] >>> shift_index[gi]);
		end
	end
endgenerate

endmodule : comb_ffe


module comb_comp #(
	parameter integer numChannels=16,
	parameter integer inputBitwidth=8,
	parameter integer thresholdBitwidth=8,
	parameter integer sym_bitwidth=2,
	parameter logic [sym_bitwidth-1:0] sym_table [(2**sym_bitwidth)-1:0] = '{2'b10, 2'b11, 2'b01, 2'b00},
	parameter logic signed [sym_bitwidth+1-1:0] sym_thrsh_table [(2**sym_bitwidth)-2:0] = '{2, 0, -2}
) (
	input wire logic signed [inputBitwidth-1:0] codes [numChannels-1:0],
	input wire logic signed [thresholdBitwidth-1:0] slice_levels [2:0],

	output logic signed [(2**sym_bitwidth-1)-1:0] sym_out [numChannels-1:0]
);
    logic [(2**sym_bitwidth)-2:0] therm_enc_slicer_outputs [numChannels-1:0];

	// I am not sure how this synthesizes vs explicitly having three thresholds and a thermometer decoder

	genvar gc;
	generate
		for(gc=0; gc<numChannels; gc=gc+1) begin
			always_comb begin

				therm_enc_slicer_outputs[gc][0] = (codes[gc] > slice_levels[0]) ? 1 : 0;
				therm_enc_slicer_outputs[gc][1] = (codes[gc] > slice_levels[1]) ? 1 : 0;
				therm_enc_slicer_outputs[gc][2] = (codes[gc] > slice_levels[2]) ? 1 : 0;


				unique case (therm_enc_slicer_outputs[gc])
					3'b000: sym_out[gc] = -3;
					3'b001: sym_out[gc] = -1;
					3'b011: sym_out[gc] = 1;
					3'b111: sym_out[gc] = 3;
					default: begin
						sym_out[gc] = 0;
						$display("Exception!");
						$display("therm_enc_slicer_outputs[%d] = %b", gc, therm_enc_slicer_outputs[gc]);
						$display("codes[%d] = %d", gc, codes[gc]);
					end
				endcase
			end
		end
	endgenerate


endmodule : comb_comp
`default_nettype wire

interface dsp_debug_intf ();

    logic signed [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0];
    logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0];
    logic signed [ffe_gpack::output_precision-1:0] slice_levels [2:0];
    logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0];
    logic [$clog2(constant_gpack::channel_width)-1:0] align_pos;
    logic signed [detector_gpack::branch_bitwidth-1:0] trellis_patterns [detector_gpack::num_of_trellis_patterns-1:0][detector_gpack::trellis_pattern_depth-1:0];


    modport dsp (
        input weights,
        input ffe_shift,
        input slice_levels,
        input channel_est,
        input channel_shift,
        input align_pos,
        input trellis_patterns
    );

endinterface : dsp_debug_intf

module simplify_dsp_dbg_intf #(
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4,
    parameter integer branch_bitwidth = 2
) (
    dsp_debug_intf.dsp dsp_dbg_intf_i,

    input logic clk,
    input logic rstb,

    output logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    output logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0] slice_levels [2:0],
    output logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    output logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0],
    output logic [$clog2(constant_gpack::channel_width)-1:0] align_pos,
    output logic signed [branch_bitwidth-1:0]  trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]
);

    always_ff @(posedge clk or negedge rstb) begin
        if (~rstb) begin
            slice_levels[0] <= 0;
            slice_levels[1] <= 0;
            slice_levels[2] <= 0;
            
            for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
                ffe_shift[ii]  <= 0;
                channel_shift[ii] <= 0;

                for(int jj=0; jj<channel_gpack::est_channel_depth; jj=jj+1) begin
                    channel_est[ii][jj] <= 0;
                end

                for(int jj=0; jj<ffe_gpack::length; jj=jj+1) begin
                    weights[jj][ii] <= 0;
                end
            end
            align_pos <= 0;

            for(int ii = 0; ii < num_of_trellis_patterns; ii = ii + 1) begin
                for(int jj = 0; jj < trellis_pattern_depth; jj = jj + 1) begin
                    trellis_patterns[ii][jj] <= 0;
                end
            end
        end else begin 
            slice_levels <= dsp_dbg_intf_i.slice_levels;
            
            for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
                ffe_shift[ii]  <= dsp_dbg_intf_i.ffe_shift[ii];
                channel_shift[ii] <= dsp_dbg_intf_i.channel_shift[ii];

                for(int jj=0; jj<channel_gpack::est_channel_depth; jj=jj+1) begin
                    channel_est[ii][jj] <= dsp_dbg_intf_i.channel_est[ii][jj];
                end

                for(int jj=0; jj<ffe_gpack::length; jj=jj+1) begin
                    weights[jj][ii] <= dsp_dbg_intf_i.weights[ii][jj];
                end
            end
            align_pos <= dsp_dbg_intf_i.align_pos;

            for(int ii = 0; ii < num_of_trellis_patterns; ii = ii + 1) begin
                for(int jj = 0; jj < trellis_pattern_depth; jj = jj + 1) begin
                    trellis_patterns[ii][jj] <= dsp_dbg_intf_i.trellis_patterns[ii][jj];
                end
            end
        end
    end
endmodule : simplify_dsp_dbg_intf


  
module bits_estimator_datapath #(
    parameter integer ffe_pipeline_depth = 0,
    parameter integer sym_bitwidth = 2,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input wire logic signed [constant_gpack::code_precision-1:0] act_codes_in [constant_gpack::channel_width-1:0],

    input wire logic clk,
    input wire logic rstb,

    output logic signed [ffe_gpack::output_precision-1:0]      est_syms_out   [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]                      symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   act_codes_out [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0]      aligned_est_syms_out   [constant_gpack::channel_width-1:0],


    input wire logic signed [ffe_gpack::weight_precision-1:0]          weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    input wire logic        [ffe_gpack::shift_precision-1:0]           ffe_shift [constant_gpack::channel_width-1:0],
    input wire logic signed [ffe_gpack::output_precision-1:0]          slice_levels [2:0],

    input wire logic [$clog2(constant_gpack::channel_width)-1:0] align_pos
);
    genvar gi;

    localparam integer total_depth             = `MAX(1, ffe_pipeline_depth)+1;
    localparam integer ffe_code_pipeline_depth = 1;

    localparam integer code_pipeline_depth     = total_depth;
    localparam integer est_bits_pipeline_depth = total_depth;
    localparam integer bits_pipeline_depth = 0;

    logic signed [constant_gpack::code_precision-1:0] act_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (constant_gpack::code_precision),
        .depth       (code_pipeline_depth)
    ) adc_code_buff_i (
        .in      (act_codes_in),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(act_codes_buffer)
    );
    

    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign act_codes_out[gi]           = act_codes_buffer[gi][code_pipeline_depth];
        end
    endgenerate

    //FFE
    logic signed [constant_gpack::code_precision-1:0] flat_act_codes [constant_gpack::channel_width*(1+ffe_code_pipeline_depth)-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (constant_gpack::code_precision),
        .buff_depth (code_pipeline_depth),
        .slice_depth(ffe_code_pipeline_depth),
        .start      (0)
    ) adc_codes_fb_i (
        .buffer    (act_codes_buffer),
        .flat_slice(flat_act_codes)
    );

    logic signed [ffe_gpack::output_precision-1:0] estimated_bits [constant_gpack::channel_width-1:0];
    comb_ffe #(
        .codeBitwidth(ffe_gpack::input_precision),
        .weightBitwidth(ffe_gpack::weight_precision),
        .resultBitwidth(ffe_gpack::output_precision),
        .shiftBitwidth(ffe_gpack::shift_precision),
        .ffeDepth(ffe_gpack::length),
        .numChannels(constant_gpack::channel_width),
        .numBuffers    (ffe_code_pipeline_depth+1),
        .t0_buff       (ffe_code_pipeline_depth)
    ) cffe_i (
        .weights       (weights),
        .flat_codes    (flat_act_codes),
        .shift_index   (ffe_shift),
        .estimated_bits(estimated_bits)
    );

    //FFE pipeline
    logic signed [ffe_gpack::output_precision-1:0] estimated_bits_buffer [constant_gpack::channel_width-1:0][est_bits_pipeline_depth:0];
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .depth      (est_bits_pipeline_depth)
    ) ffe_reg_i (
        .in (estimated_bits),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_bits_buffer)
    );

    logic signed [ffe_gpack::output_precision-1:0] buffered_estimated_bit [constant_gpack::channel_width-1:0];
    generate
        for(gi=0; gi<constant_gpack::channel_width; gi=gi+1) begin
            assign buffered_estimated_bit[gi] = estimated_bits_buffer[gi][ffe_pipeline_depth];
            assign est_syms_out[gi]           = estimated_bits_buffer[gi][total_depth];
        end
    endgenerate



    //Slicer
    wire logic signed [(2**sym_bitwidth-1)-1:0] cmp_out [constant_gpack::channel_width-1:0];

    comb_comp #(
        .numChannels(cmp_gpack::width),
        .inputBitwidth(cmp_gpack::input_precision),
        .thresholdBitwidth(cmp_gpack::input_precision)
    ) ccmp_i (
        .codes(buffered_estimated_bit),
        .slice_levels(slice_levels),
        .sym_out   (cmp_out)
    );


    //Bits Pipeline
    logic signed [(2**sym_bitwidth-1)-1:0] cmp_out_buffer  [constant_gpack::channel_width-1:0][1:0];
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (1)
    ) cmp_out_buff_i (
        .in      (cmp_out),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (cmp_out_buffer)
    );

    logic signed [(2**sym_bitwidth-1)-1:0] flat_cmp_out_bits [constant_gpack::channel_width*2-1:0];
    signed_flatten_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   ((2**sym_bitwidth-1)),
        .depth (1)
    ) cmp_out_fb_i (
        .buffer    (cmp_out_buffer),
        .flat_buffer(flat_cmp_out_bits)
    );

    signed_data_aligner #(
        .width (constant_gpack::channel_width),
        .bitwidth((2**sym_bitwidth-1)),
        .depth(2)
    ) b_algn_i (
        .data_segment(flat_cmp_out_bits),
        .align_pos(align_pos),
        .aligned_data(symbols_out)
    );


    logic signed  [ffe_gpack::output_precision-1:0] flat_estimated_bits [constant_gpack::channel_width*2-1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (ffe_gpack::output_precision),
        .buff_depth(est_bits_pipeline_depth),
        .slice_depth(1),
        .start(ffe_pipeline_depth)
    ) es_out_fb_i (
        .buffer    (estimated_bits_buffer),
        .flat_slice(flat_estimated_bits)
    );

    signed_data_aligner #(
        .width (constant_gpack::channel_width),
        .bitwidth(ffe_gpack::output_precision),
        .depth(2)
    ) es_algn_i (
        .data_segment(flat_estimated_bits),
        .align_pos(align_pos),
        .aligned_data(aligned_est_syms_out)
    );


endmodule // bits_estimator_datapath
    
module BVUnit # (
    parameter integer sym_bitwidth = 2
) (
    input wire logic signed [constant_gpack::code_precision-1:0] act_codes_in [constant_gpack::channel_width-1:0],

    input wire logic clk,
    input wire logic rstb,

    output logic signed [ffe_gpack::output_precision-1:0]      est_syms_out   [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]                      symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   act_codes_out [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0]      aligned_est_syms_out   [constant_gpack::channel_width-1:0],


    input wire logic signed [ffe_gpack::weight_precision-1:0]          weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    input wire logic        [ffe_gpack::shift_precision-1:0]           ffe_shift [constant_gpack::channel_width-1:0],
    input wire logic signed [ffe_gpack::output_precision-1:0]          slice_levels [2:0],

    input wire logic [$clog2(constant_gpack::channel_width)-1:0] align_pos
);

    bits_estimator_datapath  #(
        .ffe_pipeline_depth(constant_gpack::stage1_ffe_pipeline_depth)
    )bit_est_stage_1_i(
        .*
    );


endmodule : BVUnit