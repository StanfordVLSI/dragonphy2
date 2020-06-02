`include "mLingua_pwl.vh"

`ifndef OUT_TXT
    `define OUT_TXT
`endif

module test;
    localparam integer width   = 16;
    localparam integer depth   = 30;
    localparam integer bitwidth= 8;

    logic clk, clk_adc, rstb;
    logic clk_adc_1;
    logic clk_adc_2;
    logic clk_adc_3;

    logic [$clog2(width)-1:0] ii, next_ii;

    logic [bitwidth-1:0] values [width-1:0];
    logic [width-1:0]    signs;

    logic [bitwidth-1:0] values_r [width-1:0];
    logic [width-1:0]    signs_r;
    
    logic [bitwidth-1:0] values_retimed [width-1:0];
    logic [width-1:0]    signs_retimed;

    logic [bitwidth-1:0] prev_val;
    logic prev_sig;

    weight_clock #(.delay(468.75ps), .period(62.5ps)) clk_gen (.clk(clk));
    weight_clock #(.period(1ns)) clk_adc_gen (.clk(clk_adc));
    weight_clock #(.delay(250ps), .period(1ns)) clk_adc_gen_1 (.clk(clk_adc_1));
    weight_clock #(.delay(500ps), .period(1ns)) clk_adc_gen_2 (.clk(clk_adc_2));
    weight_clock #(.delay(750ps), .period(1ns)) clk_adc_gen_3 (.clk(clk_adc_3));
    
    initial begin
        $shm_open("wave.shm"); $shm_probe("ACT"); ii = 0; values[width-1] = 255;  signs[width-1] = 1;
        $shm_probe(values); $shm_probe(values_r); $shm_probe(values_retimed);
        $shm_probe(retimer_i.mux_out_1); $shm_probe(retimer_i.mux_out_2);
        $shm_probe(retimer_i.do_reorder);
        $shm_probe(retimer_i.pos_flop_1);
        $shm_probe(retimer_i.pos_flop_2); $shm_probe(retimer_i.pos_latch);
    end

    genvar k;
    generate
        for (k=0;k<width;k++) begin: genblk1
            //Reorder the slices
            assign values_r[k]  = values[(k%4)*4+(k>>2)];
            assign signs_r[k]   = signs[(k%4)*4+(k>>2)];
        end
    endgenerate


    always_comb begin
        next_ii  = ii + 1;
        if(ii == 0) begin
            prev_val = values[width-1];
            prev_sig = signs[width-1];
        end else begin
            prev_val = values[ii-1];
            prev_sig = signs[ii-1];
        end
    end

    always @(posedge clk) begin
        values[ii] <= prev_val + 1;
        signs[ii]  <= prev_sig + 1;
        ii         <= next_ii;
    end
    
    logic record = 1'b0;


    unsigned_ti_adc_recorder #(
        .filename(`OUT_TXT)
    ) ti_adc_recorder_i (
		.in(values_retimed),
		.clk(clk_adc),
		.en(record)
	);
    
    ti_adc_retimer_v2 retimer_i (
        .clk_retimer(clk_adc),                // clock for serial to parallel retiming

        .in_data(values_r),                     // serial data
        .in_sign(signs_r),                // sign of serial data

        .mux_ctrl_1(16'b0000111111110000),
        .mux_ctrl_2(16'b1111000000000000),

        .out_data(values_retimed),            // parallel data
        .out_sign(signs_retimed)
    );

    initial begin
        record = 0;
        repeat(4) @(posedge clk_adc);
        record = 1;
        repeat(16) @(posedge clk_adc);
        $finish;
    end


endmodule : test
