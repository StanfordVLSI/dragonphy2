// This is a D latch for the TX mux

`timescale 1fs/1fs

`default_nettype none

module dlatch_n (
    input wire logic clk,
    input wire logic din,
    output reg dout
);

always @ (clk or din) begin
    if (!clk) begin
        // non-blocking assignment used for describing a latch
        // see Guideline 2 here: http://sunburst-design.com/papers/CummingsSNUG2000SJ_NBA.pdf
        dout <= din;
    end
end

endmodule

`default_nettype wire