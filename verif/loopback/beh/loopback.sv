module loopback #(
    parameter real t_per=1e-9,
    parameter integer n_depth=32
) (
    output var logic data_tx,
    output var logic clk_tx,
    input wire logic data_rx,
    input wire logic clk_rx,
    output var logic ok
);

    // memory for previously transmitted bits
    logic mem_tx [n_depth];
    integer ptr_tx = 0;
    integer ptr_rx = 0;

    // generate the TX clock
    always begin
        clk_tx = 1'b0;
        #(0.5*t_per*1s);
        clk_tx = 1'b1;
        #(0.5*t_per*1s);
    end

    // generate the TX data
    logic bit_tx;
    always @(posedge clk_tx) begin
	// generate random bit
	bit_tx = $urandom % 2;
	// write bit to TX memory
	mem_tx[ptr_tx] = bit_tx;
	ptr_tx = (ptr_tx + 1) % n_depth;
	// transmit TX bit
        data_tx <= bit_tx;
    end

    // check the RX data
    logic bit_rx;
    always @(posedge clk_rx) begin
        // read RX bit
	bit_rx = data_rx;
	// check vs. TX memory
	if (bit_rx === mem_tx[ptr_rx]) begin
            ok = 1'b1;
	    ptr_rx = (ptr_rx + 1) % n_depth;
        end else begin
            ok = 1'b0;
        end
    end

endmodule
