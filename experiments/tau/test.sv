`timescale 1s/1fs

`include "mLingua_pwl.vh"

`ifndef CHAN_TAU
    `define CHAN_TAU 25.0e-12
`endif

`ifndef CHAN_DLY
    `define CHAN_DLY 31.25e-12
`endif

module test;

    localparam real tau=(`CHAN_TAU);
    localparam real dly=(`CHAN_DLY);

    // prbs stimulus

    logic tx_clk;
    logic tx_data;

    tx_prbs #(
        .freq(1.0e9),
        .td(dly)
    ) tx_prbs_i (
        .clk(tx_clk),
        .out(tx_data)
    );

    // TX driver

    pwl tx_p;
    pwl tx_n;

    diff_tx_driver diff_tx_driver_i (
        .in(tx_data),
        .out_p(tx_p),
        .out_n(tx_n)
    );

    // Differential channel

    pwl ch_outp;
    pwl ch_outn;

    diff_channel #(
        .tau(tau)
    ) diff_channel_i (
        .in_p(tx_p),
        .in_n(tx_n),
        .out_p(ch_outp),
        .out_n(ch_outn)
    );

    initial begin
        `ifdef DUMP_WAVEFORMS
            // Set up probing
            $shm_open("waves.shm");
            $shm_probe("ASMC");
        `endif

        // Run for several cycles
        #(100ns);

		// Finish test
		$display("Test complete.");
		$finish;
    end
endmodule
