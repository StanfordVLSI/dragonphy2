module loopback #(
    parameter integer n_addr=5
) (
    input wire logic data_tx,
    input wire logic clk_tx,
    input wire logic data_rx,
    input wire logic clk_rx,
    output var logic [63:0] number = 0
);

    // memory for previously transmitted bits
    logic mem_tx [2**n_addr];
    logic [n_addr-1:0] ptr_tx = 0;
    logic [n_addr-1:0] ptr_rx = 0;

    // record TX data
    always @(posedge clk_tx) begin
        mem_tx[ptr_tx] <= data_tx;
	    ptr_tx <= ptr_tx + 1;
    end

    // check the RX data
    always @(posedge clk_rx) begin
	    if (data_rx == mem_tx[ptr_rx]) begin
	        ptr_rx <= ptr_rx + 1;
            number <= number + 1;
        end else begin
	        ptr_rx <= ptr_rx;
            number <= 0;
        end
    end

endmodule
