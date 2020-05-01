`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``
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
	`define SIGN_FLIP 200
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
    logic [Npi-1:0] pi_ctl [Nout-1:0];
    logic [19:0] pm_out_pi [Nout-1:0];
    real Tdelay [Nout-1:0];

    pi_ctl_recorder #(
        .filename(`PI_CTL_TXT)
    ) pi_ctl_recorder_i(
    	.in(pi_ctl),
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

	// Main test
	integer pi_ctl_indiv;
	integer pm_sign_indiv;
	logic [1:0] pm_sign [Nout-1:0];
	initial begin
		// Initialize pins
		$display("Initializing pins...");
		record = 1'b0;
		jtag_drv_i.init();

		// Toggle reset
		$display("Toggling reset...");
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

		// Enable the input buffer
		$display("Set up the input buffer...");
        `FORCE_ADBG(en_inbuf, 0);
        #(1ns);
        `FORCE_ADBG(en_inbuf, 1);
        #(1ns);
		`FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);
        `FORCE_ADBG(disable_ibuf_async, 0);
        #(1ns);
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

        // run CDR clock fast to reduce simulation time
        // (the CDR clock is an input of the phase interpolator)
        `FORCE_DDBG(Ndiv_clk_cdr, 1);

        // wait for a little bit so that the CDR clock starts toggling
        #(10ns);

        // run desired number of trials
        for (int i=0; i<`N_TRIALS; i=i+1) begin
            // calculate the stimulus
            // TODO: explore behavior beyond 450
            // TODO: make test more robust with respect to sign, possibly by measuring
            // with both signs and deciding which one to use in post processing
            pi_ctl_indiv = ($urandom % 451);
            if (pi_ctl_indiv < (`SIGN_FLIP)) begin
                pm_sign_indiv = 0;
            end else begin
                pm_sign_indiv = 1;
            end

            // apply the stimulus
            for (int j=0; j<Nout; j=j+1) begin
                pi_ctl[j] = pi_ctl_indiv;
                pm_sign[j] = pm_sign_indiv;
            end
            $display("Setting ext_pi_ctl_offset to %0d...", pi_ctl_indiv);
            `FORCE_DDBG(ext_pi_ctl_offset, pi_ctl);
            `FORCE_ADBG(sel_pm_sign_pi, pm_sign);

            // wait a few cycles of the CDR clock
            $display("Waiting for a few edges of the CDR clock...");
            repeat (4) @(negedge top_i.idcore.clk_cdr);

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

        // wait a bit
        #(1ns);

        // finish the test
        $finish;
	end
endmodule