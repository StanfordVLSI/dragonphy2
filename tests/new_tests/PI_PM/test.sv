`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``

`ifndef PI_CTL_TXT
    `define PI_CTL_TXT
`endif

`ifndef DELAY_TXT
    `define DELAY_TXT
`endif

`ifndef CLK_ASYNC_FREQ
    `define CLK_ASYNC_FREQ 0.505e9
`endif

`ifndef N_TRIALS
	`define N_TRIALS 100
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
    localparam real Twait = 1.0/5.0e6;
    localparam real Nmax = Twait * `CLK_REF_FREQ;
    localparam `real_t v_cm = 0.40;

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
        // TODO: explore behavior beyond 350
        for (int i=0; i<=350; i=i+1) begin
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





    // clock inputs 
    logic clk_async_p;
    logic clk_async_n;
    logic clk_jm_p;
    logic clk_jm_n;
    logic ext_clkp;
    logic ext_clkn;
    logic signed [Nadc-1:0] adcout_conv_signed [Nti-1:0];

    // clock outputs
    logic clk_out_p;
    logic clk_out_n;
    logic clk_trig_p;
    logic clk_trig_n;
    logic clk_retime;
    logic clk_slow;
    logic rstb;
    
    // dump control
    logic dump_start;
    logic clk_cdr;

    // JTAG
    jtag_intf jtag_intf_i();

    wire logic [Nout-1:0] clk_interp;
    reg [Npi-1:0] pi_ctl [Nout-1:0];
    reg [Npi-1:0] pm_out [Nout-1:0];
    real Tdelay [Nout-1:0];

    // instantiate top module
    butterphy_top top_i (
        // analog inputs
        .ext_rx_inp(ch_outp),
        .ext_rx_inn(ch_outn),
        .ext_Vcm(v_cm),
        .ext_Vcal(v_cal),
        .ext_clk_async_p(clk_async_p),
        .ext_clk_async_n(clk_async_n),

        // clock inputs 
        .ext_clkp(ext_clkp),
        .ext_clkn(ext_clkn),

        // clock outputs
        .clk_out_p(clk_out_p),
        .clk_out_n(clk_out_n),
        .clk_trig_p(clk_trig_p),
        .clk_trig_n(clk_trig_n),
        // dump control
        .ext_dump_start(dump_start),
        .ext_rstb(rstb),
        // JTAG
        .jtag_intf_i(jtag_intf_i)
    );

    // external clock

    clock #(
        .freq(full_rate/2), //Depends on divider !
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

    // JTAG interface

    jtag_drv jtag_drv_i (jtag_intf_i);

    // Recording

    logic record;

    pi_ctl_recorder pi_ctl_recorder_i(
    	.in(pi_ctl),
    	.en(1'b1),
    	.clk(record)
    );

    delay_recorder delay_recorder_i(
    	.in(Tdelay),
    	.en(1'b1),
    	.clk(record)
    );

    // Main test logic

    logic [Npi-1:0] pi_ctl_stim [Nout-1:0] [(2**Npi-1):0];

	task pulse_record();
		record = 1'b1;
		#0;
		record = 1'b0;
		#0;
	endtask

    initial begin
    	// Initialization
        
        record = 1'b0;
        rstb = 1'b0;
        #(20ns);
        rstb = 1'b1;
        #(20ns);

        // Initialize JTAG
        
        jtag_drv_i.init();

        // Enable the input buffer

        force top_i.idcore.adbg_intf_i.en_inbuf='b1;
        force top_i.idcore.adbg_intf_i.en_v2t='b1;
        force top_i.idcore.adbg_intf_i.disable_ibuf_async = 'd0;
        force top_i.idcore.ddbg_intf_i.int_rstb ='b1;
        force top_i.idcore.ddbg_intf_i.Ndiv_clk_cdr = 'd1;

        // compute stimulus

        for (int i=0; i<Nout; i=i+1) begin
            for (int j=0; j<2**Npi; j=j+1) begin
                pi_ctl_stim[i][j] = j;
            end
            pi_ctl_stim[i].shuffle(); 
        end

        // wait for startup

        #(100ns);

        // run desired number of trials
        for (int i=0; i<`N_TRIALS; i=i+1) begin
        	// extract out the control codes to be used

            pi_ctl[0] = pi_ctl_stim[0][i];
            pi_ctl[1] = pi_ctl_stim[1][i];
            pi_ctl[2] = pi_ctl_stim[2][i];
            pi_ctl[3] = pi_ctl_stim[3][i];

            // write the control codes

            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[0] = pi_ctl[0];
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[1] = pi_ctl[1];
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[2] = pi_ctl[2];
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[3] = pi_ctl[3];

            // wait a little bit for the new phase codes to take effect
            #(10ns);

            // reset the phase monitor counter
            force top_i.idcore.adbg_intf_i.en_pm_pi[0] = 'b0;
            force top_i.idcore.adbg_intf_i.en_pm_pi[1] = 'b0;
            force top_i.idcore.adbg_intf_i.en_pm_pi[2] = 'b0;
            force top_i.idcore.adbg_intf_i.en_pm_pi[3] = 'b0;
            #(10ns);
            force top_i.idcore.adbg_intf_i.en_pm_pi[0] = 'b1;
            force top_i.idcore.adbg_intf_i.en_pm_pi[1] = 'b1;
            force top_i.idcore.adbg_intf_i.en_pm_pi[2] = 'b1;
            force top_i.idcore.adbg_intf_i.en_pm_pi[3] = 'b1;

            // wait a fixed amount of time
            #(Twait*1s);

            // Take the phase measurements
            pm_out[0] = top_i.idcore.adbg_intf_i.pm_out_pi[0];
            pm_out[1] = top_i.idcore.adbg_intf_i.pm_out_pi[1];
            pm_out[2] = top_i.idcore.adbg_intf_i.pm_out_pi[2];
            pm_out[3] = top_i.idcore.adbg_intf_i.pm_out_pi[3];

            // Compute delays
			for (int i=0; i<Nout; i=i+1) begin
				Tdelay[i] = 0.5/(1.0*`CLK_ASYNC_FREQ) * pm_out[i] / (1.0*Nmax);
			end

            // Record measured delay
            pulse_record();

            // Print status
            $display("%0.2f%% complete", 100.0*(i+1)/(1.0*`N_TRIALS));
        end

        #(1ns);

        $finish;
    end

endmodule

`default_nettype wire
