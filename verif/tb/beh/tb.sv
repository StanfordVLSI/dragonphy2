interface analog_if ();
    real value;
endinterface

module tb;

    analog_if data_tx_o ();
    analog_if data_rx_i ();

    logic clk_tx_i, data_tx_i;
    logic data_rx_o, clk_rx_o;
    logic ok;

    tx tx_i (
        .clk_i(clk_tx_i),
	.data_i(data_tx_i),
	.data_ana_o(data_tx_o)
    );

    chan chan_i (
	.data_ana_i(data_tx_o),
	.data_ana_o(data_rx_i)
    );

    rx rx_i (
	.data_ana_i(data_rx_i),
	.data_o(data_rx_o),
	.clk_o(clk_rx_o)
    );

    loopback lb_i (
	.data_tx(data_tx_i),
	.clk_tx(clk_tx_i),
	.data_rx(data_rx_o),
	.clk_rx(clk_rx_o),
	.ok(ok)
    );

    logic startup;
    initial begin
	startup = 1'b1;
	#(30ns);
	startup = 1'b0;
	#(500ns);
        $finish;
    end

    always @(startup or ok) begin
        assert (startup | ok) else $error("Loopback test failed.");
    end

endmodule
