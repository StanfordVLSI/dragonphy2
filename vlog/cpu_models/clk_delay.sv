`timescale 1s/1fs
`include "signals.sv"

module clk_delay #(
    parameter n_bits=8,
    parameter t_per=1e-9
) (
    input wire logic [(n_bits-1):0] code,
    `CLOCK_INPUT clk_i,
    `CLOCK_OUTPUT clk_o
);
    logic clk_o_clock=1'b0;
    assign clk_o.clock = clk_o_clock;

    always @(clk_i.clock) begin
        clk_o_clock <= #((code/(2.0**n_bits))*t_per*1s) clk_i.clock;
    end
endmodule
