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