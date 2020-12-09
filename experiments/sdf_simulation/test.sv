`timescale 1ns/1fs

module test;

    localparam real pi_freq=4.0e9;

	dragonphy_top top_i (
	);

    initial begin
        force top_i.itx.clk_interp_slice[0] = 1'b0;
        #((0.00/pi_freq)*1s);
        forever begin
            force top_i.itx.clk_interp_slice[0] = 1'b1;
            #((0.5/pi_freq)*1s);
            force top_i.itx.clk_interp_slice[0] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    initial begin
        force top_i.itx.clk_interp_slice[1] = 1'b0;
        #((0.25/pi_freq)*1s);
        forever begin
            force top_i.itx.clk_interp_slice[1] = 1'b1;
            #((0.5/pi_freq)*1s);
            force top_i.itx.clk_interp_slice[1] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    initial begin
        force top_i.itx.clk_interp_slice[2] = 1'b0;
        #((0.50/pi_freq)*1s);
        forever begin
            force top_i.itx.clk_interp_slice[2] = 1'b1;
            #((0.5/pi_freq)*1s);
            force top_i.itx.clk_interp_slice[2] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    initial begin
        force top_i.itx.clk_interp_slice[3] = 1'b0;
        #((0.75/pi_freq)*1s);
        forever begin
            force top_i.itx.clk_interp_slice[3] = 1'b1;
            #((0.5/pi_freq)*1s);
            force top_i.itx.clk_interp_slice[3] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

	initial begin
        // Set up probing
        // TODO: add your signals of interest here!
        $shm_open("waves.shm");
        $shm_probe(top_i.itx.din);
        $shm_probe(top_i.itx.rst_BAR);
        $shm_probe(top_i.itx.clk_interp_slice[0]);
        $shm_probe(top_i.itx.clk_interp_slice[1]);
        $shm_probe(top_i.itx.clk_interp_slice[2]);
        $shm_probe(top_i.itx.clk_interp_slice[3]);
        $shm_probe(top_i.itx.clk_halfrate);
        $shm_probe(top_i.itx.clk_prbsgen);
        $shm_probe(top_i.itx.mtb_n);
        $shm_probe(top_i.itx.mtb_p);
        $shm_probe(top_i.itx.qr_data_n);
        $shm_probe(top_i.itx.qr_data_p);

        // Initialize
        force top_i.itx.din = 16'd42; // TODO: your data here!
        force top_i.itx.rst_BAR = 1'b0;

        // De-assert reset
        #(((10.0)/pi_freq)*1s);
        force top_i.itx.rst_BAR = 1'b1;
        #(((10.0)/pi_freq)*1s);

        // TODO: run test longer / try other things?

		// Finish test
		$display("Test complete.");
		$finish;
	end

endmodule
