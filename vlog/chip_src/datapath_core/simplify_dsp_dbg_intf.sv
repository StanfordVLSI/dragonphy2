module simplify_dsp_dbg_intf (
    dsp_debug_intf.dsp dsp_dbg_intf_i,

    output logic signed [ffe_gpack::weight_precision-1:0] weights [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    output logic [ffe_gpack::shift_precision-1:0] ffe_shift [constant_gpack::channel_width-1:0],
    output logic signed [ffe_gpack::output_precision-1:0] bit_level,
    output logic signed [channel_gpack::est_channel_precision-1:0] channel_est [constant_gpack::channel_width-1:0][channel_gpack::est_channel_depth-1:0],
    output logic [channel_gpack::shift_precision-1:0] channel_shift [constant_gpack::channel_width-1:0],
    output logic  disable_product [ffe_gpack::length-1:0][constant_gpack::channel_width-1:0],
    output logic [$clog2(constant_gpack::channel_width)-1:0] align_pos
);

    always_comb begin
        bit_level <= dsp_dbg_intf_i.bit_level;
        for(int ii=0; ii<constant_gpack::channel_width; ii=ii+1) begin
            ffe_shift[ii]  <= dsp_dbg_intf_i.ffe_shift[ii];
            channel_shift[ii] <= dsp_dbg_intf_i.channel_shift[ii];

            for(int jj=0; jj<channel_gpack::est_channel_depth; jj=jj+1) begin
                channel_est[ii][jj] <= dsp_dbg_intf_i.channel_est[ii][jj];
            end

            for(int jj=0; jj<ffe_gpack::length; jj=jj+1) begin
                weights[jj][ii] <= dsp_dbg_intf_i.weights[ii][jj];
                disable_product[jj][ii] <= dsp_dbg_intf_i.disable_product[jj][ii]; //Packed to Unpacked Conversion I think requires this
            end
        end
        align_pos = dsp_dbg_intf_i.align_pos;
    end
endmodule : simplify_dsp_dbg_intf