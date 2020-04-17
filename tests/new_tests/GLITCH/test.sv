`timescale 1fs/1fs

`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

module test;

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
            	.freq(4e9),
            	.freq_tol(0.05),
            	.duty(0.5),
            	.duty_tol(0.20)
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
    logic [(Npi-1):0] pi_codes [Nout];
    initial begin
    	// Uncomment to save key signals
	    // $dumpfile("out.vcd");
	    // $dumpvars(1, top_i);
	    // $dumpvars(1, top_i.iacore);
        // $dumpvars(3, top_i.iacore.iinbuf);

        // initialize control signals
    	test_start = 1'b0;
    	test_stop = 1'b0;

		// Toggle reset
		$display("Toggling reset...");
        #(20ns);
		rstb = 1'b0;
		#(20ns);
		rstb = 1'b1;

        // Initialize JTAG
        // TODO: is this needed?
        jtag_drv_i.init();

        // Enable the input buffer
        $display("Enabling the input buffer...");
        `FORCE_ADBG(en_inbuf, 0);
		#(1ns);
        `FORCE_ADBG(en_inbuf, 1);
		#(1ns);
        `FORCE_ADBG(en_v2t, 1);
        #(1ns);
        `FORCE_ADBG(en_gf, 1);
        #(1ns);
        `FORCE_DDBG(int_rstb, 1);
        #(1ns);

        // wait a bit
        #(100ns);

        // walk through all PI codes
        for (int i=0; i<2**Npi; i=i+1) begin
        	$display("Trial %0d/%0d", i, 2**Npi);

            // write PI codes
            for (int j=0; j<Nout; j=j+1) begin
                pi_codes[j] = i;
            end
            `FORCE_DDBG(ext_pi_ctl_offset, pi_codes);

            // wait
            #(10ns);

            // start monitoring
            test_start = 'b1;
            #0;
            test_start = 'b0;
            #0;

            // wait while monitoring
            #(20ns);

            // stop monitoring
            test_stop = 'b1;
            #0;
            test_stop = 'b0;
            #0;
        end

        $finish;
    end

endmodule
