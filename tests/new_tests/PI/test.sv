`include "mLingua_pwl.vh"

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

module test;
	import test_pack::*;
	import checker_pack::*;
    import const_pack::Nout;
    import const_pack::Npi;
    import const_pack::Nunit_pi;

	// clock inputs

	logic ext_clkp;
	logic ext_clkn;

	// reset

	logic rstb;

	// JTAG driver

	jtag_intf jtag_intf_i ();
	jtag_drv jtag_drv_i (jtag_intf_i);

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

    // Convenience function

    function integer min(integer a, integer b);
        min = (a < b) ? a : b;
    endfunction

	// Main test

	integer max_sel_mux [Nout];
	integer max_ctl_pi [Nout];
	integer max_max_ctl_pi;
	integer ctl_pi;

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
        #(64ns);

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

        // test all PI CTL codes in the valid range of the PI
        for (int i=0; i<=max_max_ctl_pi; i=i+1) begin
            // determine the stimulus
            ctl_pi = i;

            // apply the stimulus
            // force statements that use loop variables don't seem to work
            $display("Setting ctl_pi to %0d...", ctl_pi);
            force top_i.iacore.ctl_pi[0] = min(ctl_pi, max_ctl_pi[0]);
            force top_i.iacore.ctl_pi[1] = min(ctl_pi, max_ctl_pi[1]);
            force top_i.iacore.ctl_pi[2] = min(ctl_pi, max_ctl_pi[2]);
            force top_i.iacore.ctl_pi[3] = min(ctl_pi, max_ctl_pi[3]);

            // wait a few cycles of the 1 GHz clock
            #(5ns);
            $display("Measured delay: %0.3f ps.", Tdelay[0]*1e12);

            // record the data
            record = 1'b1;
            #(1ns);
            record = 1'b0;
            #(1ns);
        end

        // finish the test
        $finish;
	end
endmodule
