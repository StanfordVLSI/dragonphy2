`include "signals.sv"

module loopback #(
    parameter integer n_addr=8
) (
    input wire logic data_tx,
    input wire logic clk_tx,
    input wire logic data_rx,
    input wire logic clk_rx,
    input wire logic [1:0] mode,
    output var logic [63:0] correct_bits,
    output var logic [63:0] total_bits,
    output wire logic [(n_addr-1):0] latency,
    output wire logic data_rx_o,
    output wire logic mem_rd_o
);

    // TODO: consider using enum here
    localparam logic [1:0] RESET = 2'b00;
    localparam logic [1:0] ALIGN = 2'b01;
    localparam logic [1:0]  TEST = 2'b10;

    // memory for previously transmitted bits
    logic mem [2**n_addr];

    // record TX data
    logic [(n_addr-1):0] ptr_tx;
    always @(posedge clk_tx) begin
        mem[ptr_tx] <= data_tx;
    end
    always @(posedge clk_tx) begin
        if (mode == RESET) begin
            ptr_tx <= 0;
        end else begin
	        ptr_tx <= ptr_tx + 1;
        end
    end

    // check the RX data
    logic [(n_addr-1):0] ptr_rx;
    logic mem_rd;
    always @(posedge clk_rx) begin
        mem_rd <= mem[ptr_rx];
    end
    always @(posedge clk_rx) begin
        if (mode == RESET) begin
            ptr_rx <= 0;
            correct_bits <= 64'd0;
            total_bits <= 64'd0;
        end else if (mode == ALIGN) begin
            if (data_rx == mem_rd) begin
	            ptr_rx <= ptr_rx + 1;
            end else begin
	            ptr_rx <= ptr_rx;
            end
            correct_bits <= 64'd0;
            total_bits <= 64'd0;
        end else begin
            if (data_rx == mem_rd) begin
                correct_bits <= correct_bits + 64'd1;
            end else begin
                correct_bits <= correct_bits;
            end
            ptr_rx <= ptr_rx + 1;
            total_bits <= total_bits + 64'd1;
        end
    end

    // send latency value to the output
    assign latency = ptr_tx - ptr_rx;
    assign data_rx_o = data_rx;
    assign mem_rd_o = data_tx;
endmodule
