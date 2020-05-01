`include "mLingua_pwl.vh"

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

`ifndef PI_CTL_TXT
    `define PI_CTL_TXT
`endif

`ifndef DELAY_TXT
    `define DELAY_TXT
`endif

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nout;
    import const_pack::Npi;

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

	// reset

	logic rstb;

	// JTAG driver

	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

    // stimulus parameters
    localparam real Twait = 1e-9;

	// instantiate top module

	dragonphy_top top_i (
		// clock inputs
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

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

    // Data recording
    logic record;
    logic [Npi-1:0] pi_ctl [Nout-1:0];
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

    genvar ig;
    generate
        for (ig=0; ig<Nout; ig=ig+1) begin
            delay_meas_ideal idmeas (
                .ref_in(top_i.iacore.clk_in_pi),
                .in(top_i.iacore.clk_interp_sw[ig]),
                .delay(Tdelay[ig])
            );
        end
    endgenerate

	// Main test
	initial begin
	    `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

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
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

        // run CDR clock fast to reduce simulation time
        // (the CDR clock is an input of the phase interpolator)
        `FORCE_DDBG(Ndiv_clk_cdr, 1);

        // wait for a little bit so that the CDR clock starts toggling
        #(10ns);

        // run desired number of trials
        // TODO: explore behavior beyond 450
        for (int i=0; i<=450; i=i+1) begin
            // apply the stimulus
            for (int j=0; j<Nout; j=j+1) begin
                pi_ctl[j] = i;
            end
            $display("Setting ext_pi_ctl_offset to %0d...", pi_ctl[0]);
            `FORCE_DDBG(ext_pi_ctl_offset, pi_ctl);

            // wait a few cycles of the CDR clock
            repeat (4) @(negedge top_i.idcore.clk_cdr);
            $display("Measured delay: %0.3f ps.", Tdelay[0]*1e12);

            // record the data
            record = 1'b1;
            #(1ns);
            record = 1'b0;
            #(1ns);
        end

        // wait a bit
        #(Twait*1s);

        // finish the test
        $finish;
	end
endmodule
