`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``
`define FORCE_IDCORE(name, value) force top_i.idcore.``name`` = ``value``
`define GET_ADBG(name) top_i.iacore.adbg_intf_i.``name``

`ifndef PI_CTL_TXT
    `define PI_CTL_TXT
`endif

`ifndef DELAY_TXT
    `define DELAY_TXT
`endif

`ifndef CLK_REF_FREQ
    `define CLK_REF_FREQ 4e9
`endif

`ifndef CLK_ASYNC_FREQ
    `define CLK_ASYNC_FREQ 0.505e9
`endif

`ifndef N_TRIALS
	`define N_TRIALS 25
`endif

`ifndef SIGN_FLIP
	`define SIGN_FLIP 125
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nout;
    import const_pack::Npi;

	// clock inputs
	logic ext_clkp;
	logic ext_clkn;

    // asynchronous clock inputs
    logic clk_async_p;
    logic clk_async_n;

	// reset
	logic rstb;

	// JTAG driver
	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

    // stimulus parameters
    localparam real Twait = 1.0/5.0e6;
    localparam real Nmax = Twait*(`CLK_REF_FREQ);

	// instantiate top module

	dragonphy_top top_i (
		// clock inputs
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

        // asynchronous clock inputs
        .ext_clk_async_p(clk_async_p),
        .ext_clk_async_n(clk_async_n),

        // reset
        .ext_rstb(rstb),

        // JTAG
		.jtag_intf_i(jtag_intf_i)
		// other I/O not used..
	);

	// External clock
    localparam real ext_clk_freq = full_rate/2;
	clock #(
		.freq(ext_clk_freq),
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

    // external async clock
    clock #(
        .freq(`CLK_ASYNC_FREQ),
        .duty(0.5),
        .td(0)
    ) i_clk_async (
        .ckout(clk_async_p),
        .ckoutb(clk_async_n)
    );

    // Data recording
    logic record;
    logic [19:0] pm_out_pi [Nout-1:0];
    real Tdelay [Nout-1:0];

    pi_ctl_recorder #(
        .filename(`PI_CTL_TXT)
    ) pi_ctl_recorder_i(
    	.in(top_i.iacore.ctl_pi),
    	.en(1'b1),
    	.clk(record)
    );

    delay_recorder #(
        .filename(`DELAY_TXT)
    ) delay_recorder_i(
    	.in(Tdelay),
    	.en(1'b1),
    	.clk(record)
    );

    // Convenience function

    function integer min(integer a, integer b);
        min = (a < b) ? a : b;
    endfunction

	// Main test

	integer pi_ctl_indiv;
	logic [1:0] tmp_sel_pm_sign_pi [Nout-1:0];

    integer max_sel_mux [Nout];
	integer max_ctl_pi [Nout];
	integer max_max_ctl_pi;

	initial begin
	    `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
		rstb = 1'b0;
		record = 1'b0;
        #(1ns);

		// Release reset
		$display("Releasing external reset...");
		rstb = 1'b1;
        #(1ns);

        // Initialize JTAG
        $display("Initializing JTAG...");
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

        // wait for startup so that we can read max_sel_mux
        #(10ns);

        // determine the max code range for each PI
        // the expression for the max value is from Sung-Jin on May 1, 2020
        max_max_ctl_pi = 0;
        for (int i=0; i<Nout; i=i+1) begin
            max_sel_mux[i] = `GET_ADBG(max_sel_mux[i]);
            max_ctl_pi[i] = ((max_sel_mux[i]+1)*16)-1;
            if (max_ctl_pi[i] > max_max_ctl_pi) begin
                max_max_ctl_pi = max_ctl_pi[i];
            end
        end

        // Enable the async input buffer
        $display("Enable the async input buffer...");
        `FORCE_IDCORE(disable_ibuf_async, 0);
        #(1ns);

        // Enable external max_sel_mux
        $display("Enable external max_sel_mux...");
        `FORCE_DDBG(en_ext_max_sel_mux, 1);
        #(1ns);

        // run desired number of trials
        for (int i=0; i<`N_TRIALS; i=i+1) begin
            // calculate the stimulus
            pi_ctl_indiv = ($urandom % (max_max_ctl_pi+1));

            // apply the stimulus
            // force statements that use loop variables don't seem to work
            $display("Setting ctl_pi to %0d...", pi_ctl_indiv);
            force top_i.iacore.ctl_pi[0] = min(pi_ctl_indiv, max_ctl_pi[0]);
            force top_i.iacore.ctl_pi[1] = min(pi_ctl_indiv, max_ctl_pi[1]);
            force top_i.iacore.ctl_pi[2] = min(pi_ctl_indiv, max_ctl_pi[2]);
            force top_i.iacore.ctl_pi[3] = min(pi_ctl_indiv, max_ctl_pi[3]);

            // Update signs of the PMs
            tmp_sel_pm_sign_pi[0] = top_i.iacore.ctl_pi[0] < (`SIGN_FLIP) ? 1 : 0;
            tmp_sel_pm_sign_pi[1] = top_i.iacore.ctl_pi[1] < (`SIGN_FLIP) ? 1 : 0;
            tmp_sel_pm_sign_pi[2] = top_i.iacore.ctl_pi[2] < (`SIGN_FLIP) ? 1 : 0;
            tmp_sel_pm_sign_pi[3] = top_i.iacore.ctl_pi[3] < (`SIGN_FLIP) ? 1 : 0;
            `FORCE_ADBG(sel_pm_sign_pi, tmp_sel_pm_sign_pi);
            #(1ns);

            // wait a few cycles of the 1 GHz clock
            #(5ns);

            // reset the PM
            $display("Resetting the PI PMs...");
            `FORCE_ADBG(en_pm_pi, '0);
            #(10ns);
            `FORCE_ADBG(en_pm_pi, '1);

            // wait a fixed amount of time
            $display("Waiting for the PM measurement...");
            #(Twait*1s);

            // Compute delays
			for (int j=0; j<Nout; j=j+1) begin
			    pm_out_pi[j] = `GET_ADBG(pm_out_pi[j]);
				Tdelay[j] = 0.5/(1.0*`CLK_ASYNC_FREQ) * pm_out_pi[j] / (1.0*Nmax);
			end

            // record the data
            record = 1'b1;
            #(1ns);
            record = 1'b0;
            #(1ns);

            // Print status
            $display("%0.2f%% complete", 100.0*(i+1)/(1.0*`N_TRIALS));
        end

        // finish the test
        $finish;
	end
endmodule
