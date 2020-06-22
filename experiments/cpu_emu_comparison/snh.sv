// simple model used for performance comparison with emulation

`timescale 1s/1fs

`include "iotype.sv"

module snh import const_pack::Nout; (
    input wire logic [Nout-1:0] clk,        // sampling clocks of the first s&h sw group
    input wire logic [Nout-1:0] clkb,       // ~clkb
    input `pwl_t in_p,                      // + signal input
    input `pwl_t in_n,                      // - signal input
    output `pwl_t out_p [Nout-1:0],         // sampled (+) outputs
    output `pwl_t out_n [Nout-1:0]          // sampled (-) outputs
);

    genvar i;
    generate
        for (i=0; i<Nout; i=i+1) begin
            assign out_p[i] = in_p;
            assign out_n[i] = in_n;
        end
    endgenerate

endmodule
