`define FORCE_JTAG(name, value) force top_i.idcore.jtag_i.rjtag_intf_i.``name`` = ``value``
`define GET_JTAG(name) top_i.idcore.jtag_i.rjtag_intf_i.``name``

`define SEL_ADC 2'b00
`define SEL_FFE 2'b01
`define SEL_BIST 2'b11

`define GEN_RESET 3'b000
`define GEN_UNIFORM 3'b001
`define GEN_CONSTANT 3'b010
`define GEN_INCL 3'b011
`define GEN_EXCL 3'b100
`define GEN_ALT 3'b101

`define RESET_HIST 3'b000
`define CLEAR_HIST 3'b001
`define RUN_HIST 3'b010
`define FREEZE_HIST 3'b011

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
		// external clocks
		.ext_clkp(ext_clkp),
		.ext_clkn(ext_clkn),

		// reset
        .ext_rstb(rstb),

        // JTAG
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

	// Main test

    integer k;

	logic [31:0] result;

    longint total;
    longint count [2**Nadc];
    longint total_from_hist;

    real p;

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
        `FORCE_JTAG(int_rstb, 1);
        #(1ns);
        `FORCE_JTAG(en_inbuf, 1);
		#(1ns);
        `FORCE_JTAG(en_gf, 1);
        #(1ns);
        `FORCE_JTAG(en_v2t, 1);
        #(100ns);

        // Run the data generator for a bit

        $display("Starting the data generator...");
        `FORCE_JTAG(hist_source, `SEL_BIST);
        `FORCE_JTAG(data_gen_mode, `GEN_INCL);
        `FORCE_JTAG(data_gen_in_0, 34);
        `FORCE_JTAG(data_gen_in_1, 43);
        #(100ns);

        // Clear the histogram

        $display("Clearing the histogram...");
        `FORCE_JTAG(hist_mode, `CLEAR_HIST);
        #(300ns);

        // Run the histogram for awhile

        $display("Running the histogram...");
        `FORCE_JTAG(hist_mode, `RUN_HIST);
        #(2.5us);

        // Freeze histogram

        $display("Freezing the histogram...");
        `FORCE_JTAG(hist_mode, `FREEZE_HIST);
        #(10ns);

        // get total number of counts

        total = 0;
        total |= `GET_JTAG(hist_total_upper);
        total <<= 32;
        total |= `GET_JTAG(hist_total_lower);

        $display("total: %0d", total);

        // read out the full histogram table

        total_from_hist = 0;
        for (k=0; k<(2**Nadc); k=k+1) begin
            // set the address for reading
            `FORCE_JTAG(hist_addr, k);
            #(10ns);

            // read out upper and lower part of the count
            count[k] = 0;
            count[k] |= `GET_JTAG(hist_count_upper);
            count[k] <<= 32;
            count[k] |= `GET_JTAG(hist_count_lower);

            // add to running sum
            total_from_hist += count[k];

            // display the result
            $display("count[%0d]: %0d", k, count[k]);
        end

        ////////////////
        // Check results
        ////////////////

        if (total >= 2000) begin
            $display("Total is high enough (%0d)", total);
        end else begin
            $error("Total is too low: %0d", total);
        end

        if (total == total_from_hist) begin
            $display("total matches total_from_hist");
        end else begin
            $error("total (%0d) does not match total_from_hist (%0d)",
                   total, total_from_hist);
        end

        for (k=0; k<(2**Nadc); k=k+1) begin
            p = (100.0*count[k])/(1.0*total);

            if ((34 <= k) && (k <= 43)) begin
                if ((9.9 <= p) && (p <= 10.1)) begin
                    $display("Probability OK at k=%0d (p=%0.3f%%).", k, p);
                end else begin
                    $error("Probability mismatch at k=%0d: p=%0.3f%%.", k, p);
                end
            end else begin
                if (p == 0.0) begin
                    $display("Probability OK at k=%0d (p=%0.3f%%).", k, p);
                end else begin
                    $error("Probability mismatch at k=%0d: p=%0.3f%%.", k, p);
                end
            end
        end

        //////////////
		// Finish test
		//////////////

		$finish;
	end

endmodule
