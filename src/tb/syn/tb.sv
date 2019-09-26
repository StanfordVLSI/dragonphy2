module tb;

    `DECL_ANALOG(data_tx_o);
    `DECL_ANALOG(data_rx_i);

    logic clk_tx_i, data_tx_i;
    logic data_rx_o, clk_rx_o;
    logic [63:0] number;

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
        .data_o(data_rx_o),
        .clk_o(clk_rx_o)
    );

    // tx clock
    clk_gen tx_clk_i (
        .clk_o(clk_tx_i)
    );

    // prbs
    prbs21 prbs21_i (
        .clk_i(clk_tx_i),
	    .out_o(data_tx_i)
    );

    // loopback tester
    loopback lb_i (
        .data_tx(data_tx_i),
        .clk_tx(clk_tx_i),
        .data_rx(data_rx_o),
        .clk_rx(clk_rx_o),
        .number(number)
    );

endmodule
