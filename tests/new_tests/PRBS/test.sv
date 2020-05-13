`define FORCE_ADBG(name, value) force top_i.iacore.adbg_intf_i.``name`` = ``value``
`define FORCE_DDBG(name, value) force top_i.idcore.ddbg_intf_i.``name`` = ``value``
`define FORCE_PDBG(name, value) force top_i.idcore.pdbg_intf_i.``name`` = ``value``

`define GET_PDBG(name) top_i.idcore.pdbg_intf_i.``name``

`ifndef PRBS_DEL
    `define PRBS_DEL 0
`endif

module test;
	
	import const_pack::*;
	import test_pack::*;
	import jtag_reg_pack::*;

	// clock inputs
	logic ext_clkp;
	logic ext_clkn;

	// reset
	logic rstb;

	// JTAG
	jtag_intf jtag_intf_i();
    jtag_drv jtag_drv_i (jtag_intf_i);

	// instantiate top module
	dragonphy_top top_i (
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),
        .ext_rstb(rstb),
		.jtag_intf_i(jtag_intf_i)
		// other I/O not used...
	);

	// External clock

	clock #(
		.freq(full_rate/2), // This depends on the frequency divider in the ACORE's input buffer
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

    // PRBS data generator

    logic clk_full_rate;
	clock #(
		.freq(full_rate),
		.duty(0.5),
		.td(0)
	) clock_full_rate_i (
		.ckout(clk_full_rate),
		.ckoutb()
	);

    logic clk_div_Nti;
	clock #(
		.freq(full_rate / Nti),
		.duty(0.5),
		.td(0)
	) clock_div_Nti_i (
		.ckout(clk_div_Nti),
		.ckoutb()
	);

    logic prbs_out;
    logic stim_rst;
    prbs_generator #(
        .n_prbs(7)
    ) prbs_gen_i (
        .clk(clk_full_rate),
        .rst(stim_rst),
        .cke(1'b1),
        .init_val(1),
        .out(prbs_out)
    );

    // store up a history of PRBS bits
    logic [269:0] prbs_mem;
    always @(posedge clk_full_rate) begin
        if (stim_rst == 1'b1) begin
            prbs_mem <= 0;
        end else begin
            prbs_mem <= {prbs_out, prbs_mem[269:1]};
        end
    end

    // add current PRBS bit to the history
    logic [270:0] prbs_concat;
    assign prbs_concat = {prbs_out, prbs_mem};

    // select a delayed slice of those PRBS bits
    logic [(Nti-1):0] rx_bits_imm;
    logic [(Nti-1):0] rx_bits;

    assign rx_bits_imm = prbs_concat[(270-(`PRBS_DEL)) -: Nti];

    always @(posedge clk_div_Nti) begin
        if (stim_rst == 1'b1) begin
            #(10ps);
            force top_i.idcore.prbs_rx_bits = 0;
        end else begin
            #(10ps);
            force top_i.idcore.prbs_rx_bits = rx_bits_imm;
        end
    end

    // Stimulus reset
    initial begin
        stim_rst = 1'b1;
        #(10ns);
        stim_rst = 1'b0;
    end

	// Main test

	logic [31:0] result;
    longint error_bits_1, total_bits_1;
    longint error_bits_2, total_bits_2;
    integer rx_shift;
	initial begin
		`ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif

        // initialize control signals
		rstb = 1'b0;
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

        // Toggle the PRBS block reset
        $display("Reset the PRBS tester (case 1)");
        `FORCE_DDBG(prbs_rstb, 0);
        #(10ns);
        `FORCE_DDBG(prbs_rstb, 1);
        #(10ns);

        // run the PRBS tester
        $display("Running the PRBS tester (case 1)");
        `FORCE_PDBG(prbs_checker_mode, 2);
        #(625ns);

        // get results
        `FORCE_PDBG(prbs_checker_mode, 3);
        #(10ns);

        error_bits_1 = 0;
        error_bits_1 |= `GET_PDBG(prbs_error_bits_upper);
        error_bits_1 <<= 32;
        error_bits_1 |= `GET_PDBG(prbs_error_bits_lower);

        total_bits_1 = 0;
        total_bits_1 |= `GET_PDBG(prbs_total_bits_upper);
        total_bits_1 <<= 32;
        total_bits_1 |= `GET_PDBG(prbs_total_bits_lower);

        // Change the PRBS equation and reset the tester
        $display("Reset the PRBS tester (case 2)");
        `FORCE_PDBG(prbs_checker_mode, 0);
        `FORCE_PDBG(prbs_eqn, 7'b1100001);
        #(100ns);

        // run the PRBS tester
        $display("Running the PRBS tester (case 2)");
        `FORCE_PDBG(prbs_checker_mode, 2);
        #(625ns);

        // get results
        `FORCE_PDBG(prbs_checker_mode, 3);
        #(10ns);

        error_bits_2 = 0;
        error_bits_2 |= `GET_PDBG(prbs_error_bits_upper);
        error_bits_2 <<= 32;
        error_bits_2 |= `GET_PDBG(prbs_error_bits_lower);

        total_bits_2 = 0;
        total_bits_2 |= `GET_PDBG(prbs_total_bits_upper);
        total_bits_2 <<= 32;
        total_bits_2 |= `GET_PDBG(prbs_total_bits_lower);

        // print results
        $display("n_delay: %0d", `PRBS_DEL);
        $display("error_bits_1: %0d", error_bits_1);
        $display("total_bits_1: %0d", total_bits_1);
        $display("error_bits_2: %0d", error_bits_2);
        $display("total_bits_2: %0d", total_bits_2);

        // check results

        if (!(total_bits_1 >= 9500)) begin
            $error("Not enough bits transmitted (case 1)");
        end else begin
            $display("Number of bits transmitted is OK (case 1)");
        end

        if (!(error_bits_1 == 0)) begin
            $error("Bit error detected (case 1)");
        end else begin
            $display("No bit errors detected (case 1)");
        end

        if (!(total_bits_2 >= 9500)) begin
            $error("Not enough bits transmitted (case 2)");
        end else begin
            $display("Number of bits transmitted is OK (case 2)");
        end

        if (!(error_bits_2 > 0)) begin
            $error("Bit errors should be detected (case 2)");
        end else begin
            $display("Bit errors detected, as expected for case 2");
        end

		// Finish test
		$finish;
	end

endmodule
