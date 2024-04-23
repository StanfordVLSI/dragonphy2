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


`default_nettype none
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
`default_nettype wire

module channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2,
    parameter integer sym_bitwidth = 2
) (
    input logic signed [2**sym_bitwidth-1-1:0] symstream [(depth-1)+width-1:0],
    
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift[width-1:0],

    output logic signed [est_code_bitwidth-1:0] est_code [width-1:0]
);


    localparam idx = depth - 1;


    localparam hp_depth = 6;
    localparam mp_depth = 6;
    localparam lp_depth = 18;

    localparam hp_bitwidth = est_channel_bitwidth;
    localparam mp_bitwidth = est_channel_bitwidth-2;
    localparam lp_bitwidth = est_channel_bitwidth-4;

    logic signed [hp_bitwidth-1:0] channel_hp [hp_depth-1:0];
    logic signed [mp_bitwidth-1:0] channel_mp [mp_depth-1:0];
    logic signed [lp_bitwidth-1:0] channel_lp [lp_depth-1:0];

    integer ii, jj, kk;

    always_comb begin
        for (kk = 0; kk < hp_depth; kk = kk + 1) begin
            channel_hp[kk] = {hp_bitwidth{1'b1}} & channel[0][kk];
        end
        for (kk = 0; kk < mp_depth; kk = kk + 1) begin
            channel_mp[kk] = {mp_bitwidth{1'b1}} & channel[0][kk+hp_depth];
        end
        for (kk = 0; kk < lp_depth; kk = kk + 1) begin
            channel_lp[kk] = {lp_bitwidth{1'b1}} & channel[0][kk+hp_depth+mp_depth];
        end
    end

    logic signed [est_channel_bitwidth+$clog2(depth)+ (2**2-1)-1:0] int_est_code [width-1:0];
    //logic signed [est_channel_bitwidth+$clog2(depth)+ (2**2-1)-1:0] int_est_code_tmp [width-1:0];
    //logic signed [est_channel_bitwidth+$clog2(depth)+ (2**2-1)-1:0] diff_int_est_code_tmp [width-1:0];

    logic signed [hp_bitwidth+$clog2(hp_depth)+ (2**2-1)-1:0] int_est_code_hp [width-1:0];
    logic signed [mp_bitwidth+$clog2(mp_depth)+ (2**2-1)-1:0] int_est_code_mp [width-1:0];
    logic signed [lp_bitwidth+$clog2(lp_depth)+ (2**2-1)-1:0] int_est_code_lp [width-1:0];


    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            int_est_code[ii] = 0;
            int_est_code_hp[ii] = 0;
            int_est_code_mp[ii] = 0;
            int_est_code_lp[ii] = 0;
            //int_est_code_tmp[ii] = 0;
            //diff_int_est_code_tmp[ii] = 0;
            //for(jj=0; jj<depth; jj=jj+1) begin
            //    int_est_code[ii] = int_est_code[ii] + symstream[ii+idx-jj]*channel[0][jj];
            //end
            for(jj=0; jj<hp_depth; jj=jj+1) begin
                int_est_code_hp[ii] = int_est_code_hp[ii] + symstream[ii+idx-jj]*channel_hp[jj];
            end
            for(jj=0; jj<mp_depth; jj=jj+1) begin
                int_est_code_mp[ii] = int_est_code_mp[ii] + symstream[ii+idx-jj - hp_depth]*channel_mp[jj];
            end
            for(jj=0; jj<lp_depth; jj=jj+1) begin
                int_est_code_lp[ii] = int_est_code_lp[ii] + symstream[ii+idx-jj - hp_depth - mp_depth]*channel_lp[jj];
            end

            int_est_code[ii] = int_est_code_hp[ii] + int_est_code_mp[ii] + int_est_code_lp[ii];

            est_code[ii] = int_est_code[ii] >>> shift[ii];
            //diff_int_est_code_tmp[ii] = int_est_code_tmp[ii] - int_est_code[ii];
        end
    end

endmodule : channel_filter

`default_nettype none

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

    output logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    output logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0] slice_levels [2:0],
    output logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    output logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0],
    output logic [$clog2(constant_gpack::channel_width)-1:0] align_pos,
    output logic signed [branch_bitwidth-1:0]  trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]
);

    always_comb begin
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
        align_pos = dsp_dbg_intf_i.align_pos;

        for(int ii = 0; ii < num_of_trellis_patterns; ii = ii + 1) begin
            for(int jj = 0; jj < trellis_pattern_depth; jj = jj + 1) begin
                trellis_patterns[ii][jj] = dsp_dbg_intf_i.trellis_patterns[ii][jj];
            end
        end
    end
endmodule : simplify_dsp_dbg_intf

module hargmin #(
    parameter integer num_of_energies = 3,
    parameter integer ener_bitwidth = 18
) (
    input logic [ener_bitwidth-1:0] energies [num_of_energies-1:0],

    output logic flag
);
    logic [num_of_energies-1:0] flags;

    genvar gi;
    generate
        for(gi = 1; gi < num_of_energies; gi = gi + 1) begin
            assign flags[gi] = energies[gi] < energies[0];
        end
    endgenerate

    assign flag = |flags;

endmodule

module energy_metric #(
    parameter integer est_err_bitwidth = 9,
    parameter integer seq_length = 4,
    parameter integer ener_bitwidth = 18
) (
    input logic signed [est_err_bitwidth-1:0] injection_error_seq [seq_length-1:0], 
    input logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0],

    output logic [ener_bitwidth-1:0] energy
);

    logic signed [est_err_bitwidth:0] error_diff [seq_length-1:0];
    logic        [ener_bitwidth-1:0] error_diff_sq [seq_length-1:0];

    always_comb begin
        for(int ii =0; ii < seq_length; ii = ii + 1) begin
            error_diff[ii] =  est_error[ii] - injection_error_seq[ii];
            error_diff_sq[ii] = error_diff[ii]**2;
        end

        energy = 0;
        for(int ii =0; ii < seq_length; ii = ii + 1) begin
            energy += error_diff_sq[ii];
            //$display("energy at iteration %d = %d", ii, energy);
        end
        energy = energy;
    end

endmodule

module error_injection_engine #(
        parameter integer seq_length = 3,
        parameter integer est_err_bitwidth = 9,
        parameter integer trellis_pattern_depth = 3,
        parameter integer branch_bitwidth = 2,
        parameter integer num_of_trellis_patterns = 3,
        parameter integer cp=0,
        parameter integer shift_width = 3,
        parameter integer est_channel_bitwidth = 8
) (

    input logic clk,
    inout logic rstb,

    input logic signed [est_channel_bitwidth-1:0] channel  [(seq_length+trellis_pattern_depth-1)-1:0],
    input logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
    input logic [shift_width-1:0] channel_shift,
    input logic nrz_mode,

    output logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0]
) ;

    logic signed [est_channel_bitwidth + $clog2(trellis_pattern_depth) + 1 -1:0] internal_injection_error_seqs [num_of_trellis_patterns-1:0][seq_length-1:0];
    logic signed [est_err_bitwidth-1:0] injection_error_seqs_d [2*num_of_trellis_patterns-1:0][seq_length-1:0];

    always_comb begin
        // Initialize Injection Error Sequences to Zero
        for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for(int jj =0; jj < seq_length; jj += 1) begin
                internal_injection_error_seqs[ii][jj] = 0;
            end
        end

        // Calculate the two types of injectable errors (the polarity inversed and polarity normal versions of the trellis pattern)
        for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for (int jj = 0; jj < seq_length; jj += 1) begin
                for(int kk =0; kk < trellis_pattern_depth; kk += 1) begin
                    if( cp - kk + jj >= 0) begin
                        internal_injection_error_seqs[ii][jj]   += trellis_patterns[ii][kk]*2*channel[(cp-kk) + jj];
                    end
                end
            end
        end
        for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
            for (int jj = 0; jj < seq_length; jj += 1) begin
                injection_error_seqs_d[2*ii][jj]   = internal_injection_error_seqs[ii][jj] >>> channel_shift;
                injection_error_seqs_d[2*ii+1][jj] = -internal_injection_error_seqs[ii][jj] >>> channel_shift;
            end
        end

    end

    always_ff @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            for(int ii = 0; ii < num_of_trellis_patterns; ii += 1) begin
                for(int jj =0; jj < seq_length; jj += 1) begin
                    injection_error_seqs[ii][jj] <= 0;
                end
            end
        end else begin
            for(int ii = 0; ii < 2*num_of_trellis_patterns; ii += 1) begin
                for(int jj =0; jj < seq_length; jj += 1) begin
                    injection_error_seqs[ii][jj] <= injection_error_seqs_d[ii][jj];
                end
            end
        end
    end

endmodule 
 

module rtrellis_neighbor_checker_slice #(
    parameter integer num_of_trellis_patterns = 4,
    parameter integer seq_length = 3,
    parameter integer est_err_bitwidth = 9,
    parameter integer ener_bitwidth = 18

) (
    input logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0], 
    input logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0],
    input logic signed [ener_bitwidth-1:0] null_energy,

    output logic flag
);

    logic [ener_bitwidth-1:0] energies [2*num_of_trellis_patterns:0];
    assign energies[0] = null_energy;

    genvar gi;
    generate
        for(gi = 1; gi < 2*num_of_trellis_patterns+1; gi += 1) begin
            energy_metric #(
                .est_err_bitwidth(est_err_bitwidth),
                .ener_bitwidth(ener_bitwidth),
                .seq_length(seq_length)
            ) ener_metric_i (
                .injection_error_seq(injection_error_seqs[gi-1]),
                .est_error(est_error),

                .energy(energies[gi])
            );
        end
    endgenerate

    hargmin #(
        .num_of_energies(2*num_of_trellis_patterns+1),
        .ener_bitwidth(ener_bitwidth)
    ) argmin_i (
        .energies(energies),
        .flag(flag)
    );

endmodule

module rtrellis_neighbor_checker #(
    parameter integer est_channel_bitwidth = 10,
    parameter integer depth = 30,
    parameter integer width = 16,
    parameter integer branch_bitwidth  = 2,
    parameter integer shift_bitwidth = 4,
    parameter integer trellis_neighbor_checker_depth = 2,
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4,
    parameter integer seq_length = 3,
    parameter integer ener_bitwidth = 18,
    parameter integer est_err_bitwidth=9
) (
    input logic signed [est_channel_bitwidth-1:0]          channel          [depth-1:0],
    input logic signed [shift_bitwidth-1:0]                channel_shift,
    input logic signed [branch_bitwidth-1:0]               trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
    input logic nrz_mode,
    input logic signed [est_err_bitwidth-1:0]              errstream [width*trellis_neighbor_checker_depth-1:0],

    output logic flags [width-1:0]

);
    logic signed [est_channel_bitwidth-1:0]  channel_slice [seq_length+trellis_pattern_depth-1-1:0];
    logic signed [est_err_bitwidth-1:0] errstream_slice [width-1:0][seq_length-1:0];
    logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0];
    logic [ener_bitwidth-1:0] null_energies [width-1:0];
    logic [ener_bitwidth-1:0] null_diff_sq  [width-1:0][seq_length-1:0];
    logic [ener_bitwidth-1:0] best_energies [width-1:0];

    assign channel_slice = channel[seq_length+trellis_pattern_depth-1-1:0];

    error_injection_engine #(
        .seq_length(seq_length),
        .est_err_bitwidth(est_err_bitwidth),
        .trellis_pattern_depth(trellis_pattern_depth),
        .branch_bitwidth(branch_bitwidth),
        .shift_width(shift_bitwidth),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .cp(0),
        .est_channel_bitwidth(est_channel_bitwidth)
    ) eie_i (
        .clk(clk),
        .rstb(rstb),
        .channel(channel_slice),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(nrz_mode),
        .injection_error_seqs(injection_error_seqs)
    );

    genvar gi, gj;
    generate
        for(gi = 0; gi < width; gi += 1) begin
            for(gj = 0; gj < seq_length; gj += 1) begin
                assign errstream_slice[gi][gj] = errstream[width-seq_length + gi+gj];
            end

            always_comb begin
                null_energies[gi] = 0;
                for(int ii =0; ii < seq_length; ii += 1) begin
                    null_diff_sq[gi][ii] = errstream_slice[gi][ii]**2;
                    null_energies[gi] += null_diff_sq[gi][ii];
                end
                null_energies[gi] = null_energies[gi];
            end

            rtrellis_neighbor_checker_slice #(
                .num_of_trellis_patterns(num_of_trellis_patterns),
                .seq_length(seq_length),
                .est_err_bitwidth(est_err_bitwidth),
                .ener_bitwidth(ener_bitwidth)
            ) tnc_slice_i (
                .injection_error_seqs(injection_error_seqs),
                .est_error(errstream_slice[gi]),
                .null_energy(null_energies[gi]),
                .flag(flags[gi])
            );
        end
    endgenerate

endmodule 

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

module res_err_estimator_datapath #(
    parameter integer channel_pipeline_depth      = 0,
    parameter integer sym_bitwidth = 2,
    parameter integer error_output_pipeline_depth = 0,
    parameter integer main_cursor_position        = 2,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic clk,
    input logic rstb,

    input logic signed [(2**sym_bitwidth-1)-1:0]               symbols_in [constant_gpack::channel_width-1:0],
    input logic signed [constant_gpack::code_precision-1:0]    act_codes_in [constant_gpack::channel_width-1:0],

    output logic signed [error_gpack::est_error_precision-1:0] res_err_out  [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              symbols_out [constant_gpack::channel_width-1:0],

    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift [constant_gpack::channel_width-1:0]
);
    
    genvar gi;

    localparam integer total_depth = channel_pipeline_depth  + error_output_pipeline_depth;

    localparam integer bits_pipeline_depth  = `MAX(channel_pipeline_depth + error_output_pipeline_depth, 2);
    localparam integer bits_pipeline_end    =  channel_pipeline_depth  + error_output_pipeline_depth;

    localparam integer code_pipeline_depth  = `MAX(channel_pipeline_depth, 1);
    localparam integer error_pipeline_depth = error_output_pipeline_depth;

    localparam total_channel_bit_depth  = constant_gpack::channel_width*3;
    localparam actual_channel_bit_depth = constant_gpack::channel_width + channel_gpack::est_channel_depth - main_cursor_position; // This minus two is covertly performing a bit alignment!

    //Bits Pipeline
    logic signed [(2**sym_bitwidth-1)-1:0]              symbols_buffer  [constant_gpack::channel_width-1:0][bits_pipeline_depth:0];
    logic signed [constant_gpack::code_precision-1:0]   act_codes_buffer    [constant_gpack::channel_width-1:0][code_pipeline_depth:0];
    logic signed [error_gpack::est_error_precision-1:0] est_error_buffer    [constant_gpack::channel_width-1:0][error_pipeline_depth:0];

    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_err_out[gi]   = est_error_buffer[gi][error_pipeline_depth];
            assign symbols_out[gi]    = symbols_buffer[gi][bits_pipeline_end];
        end
    endgenerate

    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (bits_pipeline_depth)
    ) sliced_bits_buff_i (
        .in      (symbols_in),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (symbols_buffer)
    );

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

    logic signed [(2**sym_bitwidth-1)-1:0] flat_symbols [total_channel_bit_depth-1:0];

    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   ((2**sym_bitwidth-1)),
        .buff_depth (bits_pipeline_depth),
        .slice_depth(2),
        .start      (0)
    ) sb_fb_i (
        .buffer    (symbols_buffer),
        .flat_slice(flat_symbols)
    );


    //Channel Filter
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes [constant_gpack::channel_width-1:0];
    logic signed [(2**sym_bitwidth-1)-1:0] section_of_flat_symbols [actual_channel_bit_depth:0];

    generate
        for(gi = 0; gi < actual_channel_bit_depth+1; gi += 1) begin
            assign section_of_flat_symbols[gi] = flat_symbols[gi + total_channel_bit_depth-1-actual_channel_bit_depth];
        end
    endgenerate

    channel_filter #(
        .sym_bitwidth(sym_bitwidth),
        .width(constant_gpack::channel_width),
        .depth(channel_gpack::est_channel_depth),
        .shift_bitwidth(channel_gpack::shift_precision),
        .est_channel_bitwidth(channel_gpack::est_channel_precision),
        .est_code_bitwidth(channel_gpack::est_code_precision)
    ) chan_filt_i (
        .symstream(section_of_flat_symbols),
        .channel(channel_est),
        .shift(channel_shift),
        .est_code(estimated_codes)
    );


    //Channel pipeline
    logic signed [channel_gpack::est_code_precision-1:0] estimated_codes_buffer [constant_gpack::channel_width-1:0][channel_pipeline_depth:0];

    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (channel_gpack::est_code_precision),
        .depth      (channel_pipeline_depth)
    ) chan_reg_i (
        .in (estimated_codes),
        .clk(clk),
        .rstb(rstb),
        .buffer(estimated_codes_buffer)
    );

    //Create Error by subtracting codes from channel filter
    logic signed [error_gpack::est_error_precision-1:0] est_error [constant_gpack::channel_width-1:0];
    logic signed [constant_gpack::code_precision-1:0]   end_buffer_adc_codes[constant_gpack::channel_width-1:0];
    logic signed [constant_gpack::code_precision-1:0]   end_buffer_est_codes[constant_gpack::channel_width-1:0];

    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            end_buffer_adc_codes[ii] = act_codes_buffer[ii][code_pipeline_depth];
            end_buffer_est_codes[ii] = estimated_codes_buffer[ii][channel_pipeline_depth];
            est_error[ii] = end_buffer_est_codes[ii] - end_buffer_adc_codes[ii];
        end
    end

    //Error pipeline
    signed_buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .depth      (error_pipeline_depth)
    ) error_reg_i (
        .in (est_error),
        .clk(clk),
        .rstb(rstb),
        .buffer(est_error_buffer)
    );

endmodule // res_err_estimator_datapath
`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module reduced_error_checker_datapath #(
    parameter integer seq_length = 3,
    parameter integer sym_bitwidth = 2,
    parameter integer branch_bitwidth = 2,
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4,
    parameter integer sliding_detector_output_pipeline_depth = 0
) (
    input logic clk,
    input logic rstb,


    input logic signed [(2**sym_bitwidth-1)-1:0]                  symbols_in             [constant_gpack::channel_width-1:0],
    input logic signed [error_gpack::est_error_precision-1:0]     res_errors_in          [constant_gpack::channel_width-1:0],


    output logic signed [error_gpack::est_error_precision-1:0]    res_errors_out         [constant_gpack::channel_width-1:0],
    output logic                                                  sd_flags               [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]                 symbols_out            [constant_gpack::channel_width-1:0],

    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est            [channel_gpack::est_channel_depth-1:0],
    input logic        [channel_gpack::shift_precision-1:0]       channel_shift          ,
    input logic signed [branch_bitwidth-1:0]                      trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]
);
    genvar gi;

    localparam integer total_depth         = sliding_detector_output_pipeline_depth;

    localparam integer bits_pipeline_depth = sliding_detector_output_pipeline_depth;
    localparam integer bits_pipeline_end   = sliding_detector_output_pipeline_depth;

    localparam integer error_pipeline_depth = `MAX(1, sliding_detector_output_pipeline_depth);
    localparam integer error_pipeline_end   = sliding_detector_output_pipeline_depth;

    logic signed [error_gpack::est_error_precision-1:0]  res_error_buffer   [constant_gpack::channel_width-1:0][error_pipeline_depth:0]; 
    logic signed [(2**sym_bitwidth-1)-1:0]               symbol_buffer [constant_gpack::channel_width-1:0][bits_pipeline_depth:0]; 

    logic [0:0]                 argmin_mmse_buffer                  [constant_gpack::channel_width-1:0][sliding_detector_output_pipeline_depth:0];

    //Flatten and slice bitstreams and errstreams
    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi += 1) begin
            assign res_errors_out[gi] = res_error_buffer[gi][error_pipeline_end];
            assign symbols_out[gi]    = symbol_buffer[gi][bits_pipeline_end];
        end
    endgenerate

    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (bits_pipeline_depth)
    ) sliced_bits_buff_i (
        .in      (symbols_in),
        .clk     (clk),
        .rstb    (rstb),
        .buffer  (symbol_buffer)
    );

    //ADC Codes Pipeline
    signed_buffer #(
        .numChannels (constant_gpack::channel_width),
        .bitwidth    (error_gpack::est_error_precision),
        .depth       (error_pipeline_depth)
    ) res_err_buff_i (
        .in      (res_errors_in),
        .clk     (clk),
        .rstb    (rstb),
        .buffer(res_error_buffer)
    );



    logic signed [error_gpack::est_error_precision-1:0] sd_flat_errors [constant_gpack::channel_width*2 - 1:0];
    signed_flatten_buffer_slice #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (error_gpack::est_error_precision),
        .buff_depth (error_pipeline_depth),
        .slice_depth(1),
        .start      (0)
    ) res_err_fb_i (
        .buffer    (res_error_buffer),
        .flat_slice(sd_flat_errors)
    );

    //Trellis Neighbor Checker
    logic [0:0] argmin_mmse [constant_gpack::channel_width-1:0];


    //always @(posedge clk) begin
    //    test_pack::array_io#(logic signed [error_gpack::est_error_precision-1:0], 32)::write_array(sd_flat_errors);
    //end

    rtrellis_neighbor_checker #(
        .est_channel_bitwidth(detector_gpack::est_channel_precision),
        .depth(channel_gpack::est_channel_depth),
        .width(constant_gpack::channel_width),
        .branch_bitwidth(2),
        .trellis_neighbor_checker_depth(2),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .trellis_pattern_depth(trellis_pattern_depth),
        .seq_length(seq_length),
        .ener_bitwidth(error_gpack::ener_bitwidth),
        .est_err_bitwidth(detector_gpack::est_error_precision)
    ) tnc_i (
        .channel(channel_est),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(0),
        .errstream(sd_flat_errors),
        .flags(argmin_mmse)
    );

    buffer #(
        .numChannels(constant_gpack::channel_width),
        .bitwidth   (1),
        .depth      (sliding_detector_output_pipeline_depth)
    ) argmin_reg_i (
        .in (argmin_mmse),
        .clk(clk),
        .rstb(rstb),
        .buffer(argmin_mmse_buffer)
    );

    always_comb begin
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            sd_flags[ii] = argmin_mmse_buffer[ii][sliding_detector_output_pipeline_depth];
        end
    end

endmodule // reduced_error_checker_datapath

module datapath_core #(
        parameter integer delay_width=4,
        parameter integer width_width=4,
        parameter integer sym_bitwidth=2,
        parameter integer branch_bitwidth=2,
        parameter integer num_of_trellis_patterns=4,
        parameter integer trellis_pattern_depth=4
)(
    input wire logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],

    input wire logic clk,
    input wire logic rstb,

    //Stage 1
    output logic signed [ffe_gpack::output_precision-1:0]      stage1_est_bits_out    [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              stage1_symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   stage1_act_codes_out [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0]      stage1_aligned_est_bits_out    [constant_gpack::channel_width-1:0],

    //Stage 2
    output logic signed [error_gpack::est_error_precision-1:0] stage2_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic signed [(2**sym_bitwidth-1)-1:0]              stage2_symbols_out [constant_gpack::channel_width-1:0],
    // Stage 3
    output logic        [0:0] stage3_sd_flags        [constant_gpack::channel_width-1:0],

    dsp_debug_intf.dsp dsp_dbg_intf_i //Stand in for Debug Interface
);

    parameter integer stage1_depth = `MAX(1, constant_gpack::stage1_ffe_pipeline_depth + 1);
    parameter integer stage2_depth = stage1_depth + constant_gpack::stage2_chan_pipeline_depth  + constant_gpack::stage2_err_out_pipeline_depth;
    parameter integer stage3_depth = stage2_depth + constant_gpack::stage3_sld_dtct_out_pipeline_depth;


    parameter integer total_depth  = stage3_depth; //stage6_depth;


    wire logic signed [ffe_gpack::weight_precision-1:0]           weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0];
    wire logic        [ffe_gpack::shift_precision-1:0]            ffe_shift [constant_gpack::channel_width-1:0];
    wire logic signed [ffe_gpack::output_precision-1:0]           slice_levels [2:0];
    wire logic signed [channel_gpack::est_channel_precision-1:0]  channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0];
    wire logic        [channel_gpack::shift_precision-1:0]        channel_shift [constant_gpack::channel_width-1:0];
    wire logic        [$clog2(constant_gpack::channel_width)-1:0] align_pos;
    wire logic signed [branch_bitwidth-1:0]                       trellis_patterns       [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0];



    simplify_dsp_dbg_intf simp_dsp_i (
        //Input 
        .dsp_dbg_intf_i(dsp_dbg_intf_i),
        //Output
        .align_pos(align_pos),
        .weights(weights),
        .ffe_shift(ffe_shift),
        .slice_levels(slice_levels),
        .channel_est(channel_est),
        .trellis_patterns(trellis_patterns),
        .channel_shift(channel_shift)
    );

    bits_estimator_datapath  #(
        .ffe_pipeline_depth(constant_gpack::stage1_ffe_pipeline_depth)
    )bit_est_stage_1_i(
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .act_codes_in(adc_codes),
        // Outputs
        .est_syms_out(stage1_est_bits_out),    
        .symbols_out(stage1_symbols_out),
        .act_codes_out(stage1_act_codes_out),
        .aligned_est_syms_out(stage1_aligned_est_bits_out),

        // JTAG Registers
        .weights(weights),
        .ffe_shift(ffe_shift),
        .slice_levels(slice_levels),
        .align_pos(align_pos)
    );

    res_err_estimator_datapath  #(
        .channel_pipeline_depth(constant_gpack::stage2_chan_pipeline_depth),
        .error_output_pipeline_depth(constant_gpack::stage2_err_out_pipeline_depth),
        .main_cursor_position(2)
    ) res_err_stage_2_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .symbols_in(stage1_symbols_out),
        .act_codes_in(stage1_act_codes_out), 

        // Outputs
        .symbols_out(stage2_symbols_out),
        .res_err_out(stage2_res_errors_out),

        // JTAG Registers
        .channel_est(channel_est),
        .channel_shift(channel_shift)
    );

    logic signed [(2**sym_bitwidth-1)-1:0]              stage3_symbols_out [constant_gpack::channel_width-1:0];
    logic signed [error_gpack::est_error_precision-1:0] stage3_res_errors_out  [constant_gpack::channel_width-1:0];

    reduced_error_checker_datapath  #(
        .seq_length(4),
        .sym_bitwidth(sym_bitwidth),
        .branch_bitwidth(2),
        .num_of_trellis_patterns(4),
        .trellis_pattern_depth(4),
        .sliding_detector_output_pipeline_depth(constant_gpack::stage3_sld_dtct_out_pipeline_depth)
    ) err_chk_stage_3_i (
        .clk(clk),
        .rstb(rstb),
        // Inputs
        .symbols_in(stage2_symbols_out),
        .res_errors_in(stage2_res_errors_out),

        // Outputs
        .sd_flags(stage3_sd_flags),       
        .symbols_out(stage3_symbols_out),
        .res_errors_out(stage3_res_errors_out),

        //JTAG Registers
        .channel_est(channel_est[0]),
        .channel_shift(channel_shift[0]),
        .trellis_patterns(trellis_patterns)
    );


endmodule : datapath_core


module EVDatapathUnit (
    input wire logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0],
    input wire logic clk,
    input wire logic rstb,

    //Stage 1
    output logic signed [ffe_gpack::output_precision-1:0]      stage1_est_bits_out    [constant_gpack::channel_width-1:0],
    output logic signed [(2**2-1)-1:0]              stage1_symbols_out [constant_gpack::channel_width-1:0],
    output logic signed [constant_gpack::code_precision-1:0]   stage1_act_codes_out [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0]      stage1_aligned_est_bits_out    [constant_gpack::channel_width-1:0],

    //Stage 2
    output logic signed [error_gpack::est_error_precision-1:0] stage2_res_errors_out  [constant_gpack::channel_width-1:0],
    output logic signed [(2**2-1)-1:0]              stage2_symbols_out [constant_gpack::channel_width-1:0],

    // Stage 3
    output logic        [0:0] stage3_sd_flags        [constant_gpack::channel_width-1:0],

    input logic signed [ffe_gpack::weight_precision-1:0] weights [constant_gpack::channel_width-1:0][ffe_gpack::length-1:0],
    input logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0],
    input logic signed [ffe_gpack::output_precision-1:0] slice_levels [2:0],
    input logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    input logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0],
    input logic [$clog2(constant_gpack::channel_width)-1:0] align_pos,
    input logic signed [detector_gpack::branch_bitwidth-1:0] trellis_patterns [detector_gpack::num_of_trellis_patterns-1:0][detector_gpack::trellis_pattern_depth-1:0]

);
    dsp_debug_intf dsp_dbg_intf_i();

    assign dsp_dbg_intf_i.weights = weights;
    assign dsp_dbg_intf_i.ffe_shift = ffe_shift;
    assign dsp_dbg_intf_i.slice_levels = slice_levels;
    assign dsp_dbg_intf_i.channel_est = channel_est;
    assign dsp_dbg_intf_i.channel_shift = channel_shift;
    assign dsp_dbg_intf_i.align_pos = align_pos;
    assign dsp_dbg_intf_i.trellis_patterns = trellis_patterns;


    datapath_core dp_core_i (
        .clk(clk),
        .rstb(rstb),
        .adc_codes(adc_codes),
        .stage1_est_bits_out(stage1_est_bits_out),
        .stage1_symbols_out(stage1_symbols_out),
        .stage1_act_codes_out(stage1_act_codes_out),
        .stage1_aligned_est_bits_out(stage1_aligned_est_bits_out),
        .stage2_res_errors_out(stage2_res_errors_out),
        .stage2_symbols_out(stage2_symbols_out),
        .stage3_sd_flags(stage3_sd_flags),
        .dsp_dbg_intf_i(dsp_dbg_intf_i)
    );



endmodule : EVDatapathUnit