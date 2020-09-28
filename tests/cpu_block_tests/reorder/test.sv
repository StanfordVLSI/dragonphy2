`timescale 1s/1fs

`include "mLingua_pwl.vh"

`ifndef OUT_TXT
    `define OUT_TXT
`endif

`ifndef REP_TXT
    `define REP_TXT
`endif

module test;
    localparam integer width = 16;
    localparam integer bitwidth = 8;
    localparam integer rep = 2;

    logic signed [bitwidth-1:0] adc_data_in [(width-1):0];
    logic signed [bitwidth-1:0] rep_data_in [(rep-1):0];

    logic [(bitwidth-1):0] in_data [(width-1):0];
    logic [(width-1):0] in_sign;

    logic [(bitwidth-1):0] in_data_rep [(rep-1):0];
    logic [(rep-1):0] in_sign_rep;

    logic [(bitwidth-1):0] out_data [(width-1):0];
    logic [(width-1):0] out_sign;

    logic [(bitwidth-1):0] out_data_rep [(rep-1):0];
    logic [(rep-1):0] out_sign_rep;

    logic signed [bitwidth-1:0] adc_data_out [(width-1):0];
    logic signed [bitwidth-1:0] rep_data_out [(rep-1):0];

    // magnitude/sign conversion

    genvar i;
    generate
        for (i=0; i<width; i=i+1) begin
            always_comb begin
                in_data[i] = (adc_data_in[i] >= 0) ? adc_data_in[i] : (-adc_data_in[i]);
                in_sign[i] = (adc_data_in[i] >= 0) ? 1'b1 : 1'b0;
                adc_data_out[i] = out_sign[i] ? out_data[i] : (-out_data[i]);
            end
        end
        for (i=0; i<rep; i=i+1) begin
            always_comb begin
                in_data_rep[i] = (rep_data_in[i] >= 0) ? rep_data_in[i] : (-rep_data_in[i]);
                in_sign_rep[i] = (rep_data_in[i] >= 0) ? 1'b1 : 1'b0;
                rep_data_out[i] = out_sign_rep[i] ? out_data_rep[i] : (-out_data_rep[i]);
            end
        end
    endgenerate

    // reordering

    ti_adc_reorder reorder_i (
        .in_data(in_data),
        .in_sign(in_sign),
        .in_data_rep(in_data_rep),
        .in_sign_rep(in_sign_rep),
        .out_data(out_data),
        .out_sign(out_sign),
        .out_data_rep(out_data_rep),
        .out_sign_rep(out_sign_rep)
    );

    // data recording

    logic clk_adc;

    ti_adc_recorder #(
        .filename(`OUT_TXT)
    ) adc_rec_i (
		.in(adc_data_out),
		.clk(clk_adc),
		.en(1'b1)
	);

    ti_adc_recorder #(
        .num_channels(2),
        .filename(`REP_TXT)
    ) rep_rec_i (
		.in(rep_data_out),
		.clk(clk_adc),
		.en(1'b1)
	);

    // main test logic

    integer j, k, offset;
    integer stimulus [2**bitwidth];

    initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize the clock
        clk_adc = 0;

        // initialize data to be written
        for (j=0; j<(2**bitwidth); j=j+1) begin
            stimulus[j] = j-128;
        end

        // write the replica values
        rep_data_in[0] = +12;
        rep_data_in[1] = -34;

        // write the data
        for (j=0; j < (2**bitwidth)/width; j=j+1) begin
            offset = j*width;
            for (k=0; k < width; k=k+1) begin
                adc_data_in[k] = stimulus[offset + (k/4) + (k%4)*4];
            end
            #(1ns);
            clk_adc = 1'b1;
            #(1ns);
            clk_adc = 1'b0;
            #(1ns);
        end

        // finish the test
        $finish;
    end

endmodule : test
