`include "signals.sv"

module rx (
    `ANALOG_INPUT data_ana_i,
    input wire logic rstb,
    output wire logic clk_o,
    output wire logic data_o
);
    // instantiate the clock
    // TODO: figure out a cleaner way to pass clk_o_val
    logic clk_imm, clk_imm_val;
    osc_model rx_clk_i (
        .clk_o(clk_imm),
        .clk_o_val(clk_imm_val)
    );

    // delay the clock by an adjustable amount
    // TODO: figure out a cleaner way to pass clk_o_val
    logic [7:0] del_code;
    logic clk_o, clk_o_val;
    clk_delay clk_delay_i (
        .code(del_code),
        .clk_i(clk_imm),
        .clk_i_val(clk_imm_val),
        .clk_o(clk_o),
        .clk_o_val(clk_o_val)
    );

    // instantiate the ADC
    // TODO: Fix this hack for channelized interface
    // TODO: figure out a cleaner way to pass clk_o_val
    logic signed [7:0] adc_o [0:0];
    rx_adc rx_adc_i (
        .in(data_ana_i),
        .out(adc_o[0]),
        .clk(clk_o),
        .clk_val(clk_o_val),
        .rst(~rstb)
    );

    // Measure phase and adjust sampling point
    // TODO: cleanup hierarchy
    logic signed [1:0] pd_o;
    mm_pd mm_pd_i (
        .clk(clk_o),
        .rstb(rstb),
        .data_i(adc_o[0]),
        .pi_ctl(del_code)
    );

    // slice data
    assign data_o = (adc_o[0] > 0) ? 1'b1 : 1'b0;

    //// Import packages needed for FFE
    //import weights_pack::*;
    //import constant_gpack::*;
//
    //// instantiate the FFE
    //// logic signed [ffe_gpack::output_precision-1:0]  ffe_o  	        [ffe_gpack::width-1:0];
    //// logic signed [ffe_gpack::weight_precision-1:0]  weights        [ffe_gpack::length-1:0][ffe_gpack::width-1:0];
    //// logic [ffe_gpack::shift_precision-1:0] shift_default = ffe_shift;
    //// logic [ffe_gpack::shift_precision-1:0] shift_index  [ffe_gpack::width-1:0];
//
    //flat_ffe #(
    //    .ffeDepth(ffe_gpack::length),
    //    .numChannels(ffe_gpack::width),
    //    .codeBitwidth(ffe_gpack::input_precision),
    //    .weightBitwidth(ffe_gpack::weight_precision),
    //    .resultBitwidth(ffe_gpack::output_precision),
    //    .shiftBitwidth   (ffe_gpack::shift_precision )
    //) ffe_inst (
    //    .clk(clk_o),
    //    // TODO: fixme
    //    .rstb(rstb),
    //    .new_shift_index(shift_index),
    //    .new_weights(weights),
    //    .codes      (adc_o),
    //    .results    (ffe_o)
    //);
//
    //// initialize weights and shift_index
    //genvar gi,gj;
    //generate
    //    for(gi=0; gi<ffe_gpack::length; gi=gi+1) begin
    //        for(gj=0; gj<ffe_gpack::width; gj=gj+1) begin
    //            assign weights[gi][gj] = read_weights[gi];
    //        end
    //    end
    //    for(gj=0;gj<ffe_gpack::width;gj=gj+1) begin
    //        assign shift_index[gj] = shift_default;
    //    end
    //endgenerate
//
    //// create digital comparator
    //logic cmp_o [ffe_gpack::width-1:0];
    //generate
    //    for (gi=0; gi<ffe_gpack::width;gi+=1) begin
    //        assign cmp_o[gi] = (ffe_o[gi] > 0) ? 1'b1 : 1'b0;
    //    end
    //endgenerate
endmodule
