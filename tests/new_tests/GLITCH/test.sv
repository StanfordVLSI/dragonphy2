`timescale 1fs/1fs

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

// please set the values for these variables in the Python script!
// documentation for each can be found there

`ifndef PI_CLK_FREQ
    `define PI_CLK_FREQ 4.0e9
`endif

`ifndef CDR_CLK_FREQ
    `define CDR_CLK_FREQ 1.0e9
`endif

`ifndef N_TRIALS
    `define N_TRIALS 550
`endif

`ifndef MONITOR_TIME
    `define MONITOR_TIME 5e-9
`endif

`ifndef WIDTH_TOL
    `define WIDTH_TOL 2e-12
`endif

`ifndef INITIAL_CODE
    `define INITIAL_CODE 0
`endif

`ifndef INITIAL_DIR
    `define INITIAL_DIR +1
`endif

module test;
 	parameter max_sel_mux = 15;
    import const_pack::*;
    import test_pack::*;
    import checker_pack::*;

    // external clock inputs
    logic ext_clkp, ext_clkn;
    clock #(
        .freq(full_rate/2),
        .duty(0.5),
        .td(0)
    ) iEXTCLK (
        .ckout(ext_clkp),
        .ckoutb(ext_clkn)
    );

    // reset signal
    logic rstb;

    // JTAG
    jtag_intf jtag_intf_i();
    jtag_drv jtag_drv_i (jtag_intf_i);

    // instantiate glitch testers
    logic test_start, test_stop;
    generate
        for (genvar i=0; i<Nout; i=i+1) begin : glitch_test_gen
            glitch_test #(
            	.freq(`PI_CLK_FREQ),
            	.width_tol(`WIDTH_TOL)
            ) glitch_test_i (
                .in(top_i.iacore.clk_interp_sw[i]),
                .start(test_start),
                .stop(test_stop)
            );
        end
    endgenerate

    // instantiate top module
    dragonphy_top top_i (
        // clock inputs 
        .ext_clkp(ext_clkp),
        .ext_clkn(ext_clkn),

        // reset
        .ext_rstb(rstb),

        // JTAG
        .jtag_intf_i(jtag_intf_i)
    );

    // Main test logic
    real delay;
    integer code_delta;
    logic [(Npi-1):0] pi_ctl_indiv;
    logic [(Npi-1):0] pi_ctl_prev;
    initial begin
         `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif
	
        // initialize control signals
    	test_start = 1'b0;
    	test_stop = 1'b0;
    	pi_ctl_indiv = (`INITIAL_CODE);
    	code_delta = (`INITIAL_DIR);
		rstb = 1'b0;
        #(1ns);

        // set en_inbuf to "0"
        // TODO: update value in JTAG register
        `FORCE_ADBG(en_inbuf, 0);
        #(1ns);

        // set all PI codes to pi_ctl_indiv
        force top_i.iacore.ctl_pi[0] = pi_ctl_indiv;
        force top_i.iacore.ctl_pi[1] = pi_ctl_indiv;
        force top_i.iacore.ctl_pi[2] = pi_ctl_indiv;
        force top_i.iacore.ctl_pi[3] = pi_ctl_indiv;
        #(1ns);

        // run CDR clock fast to reduce simulation time
        // (the CDR clock is an input of the phase interpolator)
        `FORCE_DDBG(Ndiv_clk_cdr, 1);
        #(1ns);

		// Release reset
		$display("Toggling reset...");
		rstb = 1'b1;

        // Initialize JTAG
        // TODO: what is the right place in the reset sequence for this?
        jtag_drv_i.init();

        // Soft reset sequence
        $display("Soft reset sequence...");
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
		#(1ns);
        `FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);

        // wait for a little bit so that the CDR clock starts toggling
        #(10ns);

        // start the test
        $display("Starting the test...");
        test_start = 1;
        #(10ns);

        // run desired number of trials
        for (int i=0; i<(`N_TRIALS); i=i+1) begin
            // synchronize to the beginning of the CDR clock period
            @(posedge top_i.iacore.clk_cdr);

            // wait a random amount of time within the CDR clock period
            delay = (($urandom%10000)/10000.0)/(`CDR_CLK_FREQ);
            #(delay*1s);

            // increment/decrement the PI control code
            pi_ctl_prev = pi_ctl_indiv;
            pi_ctl_indiv = pi_ctl_indiv + code_delta;
            if (pi_ctl_indiv == 0) begin
                code_delta = +1;
            //end else if (pi_ctl_indiv == ((2**Npi)-1)) begin
            end else if (pi_ctl_indiv == ((max_sel_mux+1)*16-1)) begin
                code_delta = -1;
            end

            // apply the stimulus
            force top_i.iacore.ctl_pi[0] = pi_ctl_indiv;
            force top_i.iacore.ctl_pi[1] = pi_ctl_indiv;
            force top_i.iacore.ctl_pi[2] = pi_ctl_indiv;
            force top_i.iacore.ctl_pi[3] = pi_ctl_indiv;

            // wait while monitoring
            #((`MONITOR_TIME)*1s);

            // print status
            $display("%0.2f%% complete [code %0d -> %0d]",
                     100.0*(i+1)/(1.0*`N_TRIALS),
                     pi_ctl_prev, pi_ctl_indiv);
        end

        // end test
        test_stop = 'b1;
        #(10ns);

        $finish;
    end

endmodule
