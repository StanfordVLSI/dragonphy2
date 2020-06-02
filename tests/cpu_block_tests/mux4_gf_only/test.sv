`timescale 1fs/1fs

`define FREQ 4e9
`define DUTY 0.5
`define N_TRIALS 1000
`define NOM_DELAY 30e-12

module test;
    // Generate 4 GHz clock
    logic ext_clkp, ext_clkn;
    clock #(
        .freq(`FREQ),
        .duty(`DUTY),
        .td(0)
    ) iEXTCLK (
        .ckout(clk),
        .ckoutb()
    );

    // Generate delayed clocks
    // Clock edge timing is randomized around
    // the nominal position to help ensure
    // glitches are seen even if there is a
    // lucky cancellation of nominal delays.

    logic [3:0] clki;
    assign clki[0] = clk;
    assign #(((`NOM_DELAY)+0.37e-12)*1s) clki[1] = clki[0];
    assign #(((`NOM_DELAY)+0.25e-12)*1s) clki[2] = clki[1];
    assign #(((`NOM_DELAY)-0.13e-12)*1s) clki[3] = clki[2];

    // Instantiate the muxes
    logic en_gf;
    logic [1:0] sel;
    logic clko;

    mux4_gf mux4_gf_i (
        .en_gf(en_gf),
        .sel(sel),
        .in(clki),
        .out(clko)
    );

    // Instantiate the glitch tester
    logic test_start, test_stop;
    glitch_test #(
        .freq(`FREQ),
        .duty(`DUTY),
        .width_tol((`NOM_DELAY)+4e-12)
    ) glitch_test_i (
        .in(clko),
        .start(test_start),
        .stop(test_stop)
    );

    // Main test logic
    real delay;
    integer code_delta;
    initial begin
         `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
    	test_start = 0;
    	test_stop = 0;
        en_gf = 0;
        sel = 0;
        code_delta = +1;
        #(10ns);

        // set en_gf -> 1
        en_gf = 1;
        #(10ns);

        // enable the test
        test_start = 1;
        #(10ns);

        // run desired number of trials
        for (int i=0; i<(`N_TRIALS); i=i+1) begin
            // synchronize to the beginning of the period
            @(posedge clk);

            // wait a random amount of time within the period
            delay = (($urandom%10000)/10000.0)/(`FREQ);
            #(delay*1s);

            // then increment/decrement the select code
            sel = sel + code_delta;
            if (sel == 0) begin
                code_delta = +1;
            end else if (sel == 3) begin
                code_delta = -1;
            end

            // wait while monitoring
            #(20ns);

            // print status
            $display("%0.2f%% complete", 100.0*(i+1)/(1.0*`N_TRIALS));
        end

        // end test
        test_stop = 'b1;
        #(10ns);

        $finish;
    end

endmodule
