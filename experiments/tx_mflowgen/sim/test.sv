`timescale 1ns/1fs

module test;

    localparam real pi_freq=4.0e9;

    logic [15:0] din;
    logic [3:0] clk_interp_slice;
    logic rst;
    logic clk_prbsgen;
    logic dout_p;
    logic dout_n;

    tx_top top_i (
        .din(din),
        .clk_interp_slice(clk_interp_slice),
        .rst(rst),
        .clk_prbsgen(clk_prbsgen),
        .dout_p(dout_p),
        .dout_n(dout_n)
    );


    initial begin
        clk_interp_slice[0] = 1'b0;
        #((0.00/pi_freq)*1s);
        forever begin
            clk_interp_slice[0] = 1'b1;
            #((0.5/pi_freq)*1s);
            clk_interp_slice[0] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    initial begin
        clk_interp_slice[1] = 1'b0;
        #((0.25/pi_freq)*1s);
        forever begin
            clk_interp_slice[1] = 1'b1;
            #((0.5/pi_freq)*1s);
            clk_interp_slice[1] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    initial begin
        clk_interp_slice[2] = 1'b0;
        #((0.50/pi_freq)*1s);
        forever begin
            clk_interp_slice[2] = 1'b1;
            #((0.5/pi_freq)*1s);
            clk_interp_slice[2] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    initial begin
        clk_interp_slice[3] = 1'b0;
        #((0.75/pi_freq)*1s);
        forever begin
            clk_interp_slice[3] = 1'b1;
            #((0.5/pi_freq)*1s);
            clk_interp_slice[3] = 1'b0;
            #((0.5/pi_freq)*1s);
        end
    end

    integer k;
	initial begin
        // Set up probing
        // TODO: add your signals of interest here!
        $shm_open("waves.shm");
        $shm_probe("ASMC");

        // Initialize
        din = 16'd42; // TODO: your data here!
        rst = 1'b1;

        // Toggle reset
        #(((10.0)/pi_freq)*1s);
        rst = 1'b0;
        #(((10.0)/pi_freq)*1s);

        // TODO: run test longer / try other things?

		// Finish test
		$display("Test complete.");
		$finish;
	end

endmodule
