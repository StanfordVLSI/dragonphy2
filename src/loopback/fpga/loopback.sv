`include "signals.sv"

module loopback #(
    parameter integer n_addr=5
) (
    input wire logic data_tx,
    input wire logic clk_tx,
    input wire logic data_rx,
    input wire logic clk_rx,
    output var logic [63:0] number
);

    // memory for previously transmitted bits
    logic mem [2**n_addr];

    // record TX data
    logic [n_addr-1:0] ptr_tx;
    always @(posedge clk_tx) begin
        mem[ptr_tx] <= data_tx;
    end
    always @(posedge clk_tx) begin
        if (`EMU_RST) begin
            ptr_tx <= 0;
        end else begin
	        ptr_tx <= ptr_tx + 1;
        end
    end

    // check the RX data
    logic [n_addr-1:0] ptr_rx = 0;
    logic mem_rd;
    always @(posedge clk_rx) begin
        mem_rd <= mem[ptr_rx];
    end
    always @(posedge clk_rx) begin
        if (`EMU_RST) begin
            number <= 0;
            ptr_rx <= 0;
        end else if (data_rx == mem_rd) begin
	        ptr_rx <= ptr_rx + 1;
            number <= number + 1;
        end else begin
	        ptr_rx <= ptr_rx;
            number <= 0;
        end
    end

endmodule
