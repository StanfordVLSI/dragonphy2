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
        .n_prbs(Nprbs)
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
    longint correct_bits, total_bits;
    integer rx_shift;
	initial begin
	    // Uncomment to save key signals
	    // $dumpfile("out.vcd");
	    // $dumpvars(1, test);
	    // $dumpvars(1, top_i.idcore);
	    // $dumpvars(3, top_i.idcore.prbs_checker_i);

		// Initialize pins
		$display("Initializing pins...");
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

        // Toggle the PRBS block reset
        `FORCE_DDBG(prbs_rstb, 0);
        #(10ns);
        `FORCE_DDBG(prbs_rstb, 1);
        #(10ns);

        // align the PRBS tester
        $display("Aligning the PRBS tester");
        `FORCE_PDBG(prbs_checker_mode, 1);
        #(625ns);

        // run the PRBS tester
        $display("Running the PRBS tester");
        `FORCE_PDBG(prbs_checker_mode, 2);
        #(625ns);

        // get results
        correct_bits = 0;
        correct_bits |= `GET_PDBG(prbs_correct_bits_upper);
        correct_bits <<= 32;
        correct_bits |= `GET_PDBG(prbs_correct_bits_lower);

        total_bits = 0;
        total_bits |= `GET_PDBG(prbs_total_bits_upper);
        total_bits <<= 32;
        total_bits |= `GET_PDBG(prbs_total_bits_lower);

        rx_shift = `GET_PDBG(prbs_rx_shift);

        // print results
        $display("n_delay: %0d", `PRBS_DEL);
        $display("correct_bits: %0d", correct_bits);
        $display("total_bits: %0d", total_bits);
        $display("rx_shift: %0d", rx_shift);

        if (!(total_bits >= 9500)) begin
            $error("Not enough bits transmitted.");
        end else begin
            $display("Number of bits transmitted is OK.");
        end

        if (!(correct_bits == total_bits)) begin
            $error("Bit error detected.");
        end else begin
            $display("No bit errors detected :-)");
        end

		// Finish test
		$finish;
	end

endmodule
