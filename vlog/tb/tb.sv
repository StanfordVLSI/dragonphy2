`include "signals.sv"

module tb;
    // analog signals
    `DECL_ANALOG(data_tx_o);
    `DECL_ANALOG(data_rx_i);

    // clock + data
    logic clk_tx_i, data_tx_i;
    logic clk_rx_o, data_rx_o;

    // reset signals
    logic prbs_rst;
    logic rx_rstb;

    // loopback tester signals
    logic [1:0] lb_mode;
    logic [7:0] lb_latency;
    logic [63:0] lb_correct_bits;
    logic [63:0] lb_total_bits;

    // RX/TX bits for VIO
    logic mem_rd;
    logic data_rx;

    // transmitter
    tx tx_i (
        .clk_i(clk_tx_i),
        .data_i(data_tx_i),
        .data_ana_o(data_tx_o)
    );

    // channel
    chan chan_i (
        .data_ana_i(data_tx_o),
        .data_ana_o(data_rx_i)
    );

    // receiver
    rx rx_i (
        .data_ana_i(data_rx_i),
        .rstb(rx_rstb),
        .data_o(data_rx_o),
        .clk_o(clk_rx_o)
    );

    // tx clock
    osc_model tx_clk_i (
        .clk_o(clk_tx_i)
    );

    // prbs
    prbs21 prbs21_i (
	    .out_o(data_tx_i),
        .clk_i(clk_tx_i),
        .rst_i(prbs_rst)
    );

    // loopback tester
    loopback lb_i (
        .data_tx(data_tx_i),
        .clk_tx(clk_tx_i),
        .data_rx(data_rx_o),
        .clk_rx(clk_rx_o),
        .mode(lb_mode),
        .correct_bits(lb_correct_bits),
        .total_bits(lb_total_bits),
        .latency(lb_latency),
        .mem_rd_o(mem_rd), 
        .data_rx_o(data_rx)
    );

    // needed for time management infrastructure
    // will be cleaned up in a future commit
    tm_stall tm_stall_i ();
endmodule
