`ifndef CHANNEL_TXT
    `define CHANNEL_TXT
`endif

`ifndef WEIGHT_TXT
    `define WEIGHT_TXT
`endif

class File #(
    parameter integer bitwidth=8,
    parameter integer depth   =10,
    parameter string file_name = "channel.txt",
    parameter type T = logic signed [bitwidth-1:0]
);
    static task load_array(output T values [depth-1:0]);
        integer ii, fid;
        fid = $fopen(file_name, "r");

        for(ii=0; ii < depth; ii=ii+1) begin
            $fscanf(fid, "%d", values[ii]);
        end

        $fclose(fid);
    endtask : load_array
endclass : File

class Broadcast #(
    parameter integer bitwidth=8,
    parameter integer width   =16,
    parameter integer depth   =10,
    parameter type T = logic signed [bitwidth-1:0]
    );

    static task all(input T broadcast_values [depth-1:0], output T broadcast_target [width-1:0][depth-1:0] );
        integer ii, jj;
        $display($typename(broadcast_values));
        for(ii=0; ii < width; ii=ii+1) begin
            for(jj =0; jj < depth; jj=jj+1) begin
                broadcast_target[ii][jj] = broadcast_values[jj];
            end
        end
    endtask : all
endclass : Broadcast

module test ();
    Broadcast #(
        channel_gpack::est_channel_precision,
        constant_gpack::channel_width, 
        channel_gpack::est_channel_depth
    ) broadcast_channel;

    Broadcast #(
        ffe_gpack::weight_precision, 
        constant_gpack::channel_width, 
        ffe_gpack::length
    ) broadcast_weights;

    File #(
        .bitwidth(channel_gpack::est_channel_precision), 
        .depth(channel_gpack::est_channel_depth),
        .file_name(`CHANNEL_TXT)
    ) file_channel;

    File #(
        .bitwidth(ffe_gpack::weight_precision),
        .depth(ffe_gpack::length),
        .file_name(`WEIGHT_TXT)
    ) file_weights;

    logic signed [constant_gpack::code_precision-1:0] adc_codes [constant_gpack::channel_width-1:0];
    logic signed [channel_gpack::est_channel_precision-1:0] channel_est [channel_gpack::est_channel_depth-1:0];
    logic signed [ffe_gpack::weight_precision-1:0] ffe_weights [ffe_gpack::length-1:0];

    logic clk, rstb, start;


    weight_clock #(.period(1ns)) clk_gen (.clk(clk), .en(start));

    dsp_debug_intf dsp_dbg_intf_i();
    datapath_core #(
        .ffe_pipeline_depth(1), 
        .channel_pipeline_depth(1), 
        .additional_error_pipeline_depth(0), 
        .sliding_detector_output_pipeline_depth(0)
    ) dp_core_i (
        .adc_codes(adc_codes),
        .clk(clk),
        .rstb(rstb),
        .dsp_dbg_intf_i(dsp_dbg_intf_i)
    );


    genvar gi, gj;
    generate
        for(gi = 0; gi < constant_gpack::channel_width; gi = gi + 1) begin
            assign dsp_dbg_intf_i.ffe_shift[gi] = 0;
            assign dsp_dbg_intf_i.thresh[gi] = 0;

            assign dsp_dbg_intf_i.channel_shift[gi] = 0;
            for(gj = 0; gj < ffe_gpack::length; gj = gj + 1 ) begin
                assign dsp_dbg_intf_i.disable_product[gj][gi] = 0;
            end
        end
    endgenerate

    initial begin
        $shm_open("waves.shm"); $shm_probe("ASMC");
    end

    integer ii, jj;

    always_ff @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            for(ii = 0; ii < constant_gpack::channel_width; ii = ii + 1) begin
                adc_codes[ii] <= 0;
            end
        end else begin
            for(ii = 0; ii < constant_gpack::channel_width; ii = ii + 1) begin
                adc_codes[ii] <= $signed(($urandom() % 2) ? +1 : -1);
            end
        end
    end

    initial begin
        rstb = 0;
        start = 0;
        $display(`CHANNEL_TXT);
        $display(`WEIGHT_TXT);
        file_channel.load_array(channel_est);
        file_weights.load_array(ffe_weights);

        broadcast_channel.all(channel_est, dsp_dbg_intf_i.channel_est);
        broadcast_weights.all(ffe_weights, dsp_dbg_intf_i.weights);
        start = 1;
        @(posedge clk) rstb = 1; 
         
        repeat (50) @(posedge clk);


        $finish;
    end

endmodule : test

