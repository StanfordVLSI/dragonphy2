`include "svreal.sv"

module test_chan_model #(
    parameter integer width0=18,
    parameter integer width1=18,
    parameter integer naddr=9
) (
    input real in_,
    output real out,
    input real dt_sig,
    input clk,
    input cke,
    input rst,
    input [(width0-1):0] wdata0,
    input [(width1-1):0] wdata1,
    input [(naddr-1):0] waddr,
    input we
);
    // wire input
    `REAL_FROM_WIDTH_EXP(in_int, 18, -12);
    assign `FORCE_REAL(in_, in_int);

    // wire output
    `REAL_FROM_WIDTH_EXP(out_int, 18, -12);
    assign out = `TO_REAL(out_int);

    // wire dt
    `REAL_FROM_WIDTH_EXP(dt_int, 27, -46);
    assign `FORCE_REAL(dt_sig, dt_int);

    // instantiate model
    chan_core #(
        `PASS_REAL(in_, in_int),
        `PASS_REAL(out, out_int),
        `PASS_REAL(dt_sig, dt_int)
    ) chan_core_i (
        .in_(in_int),
        .out(out_int),
        .dt_sig(dt_int),
        .clk(clk),
        .cke(cke),
        .rst(rst),
        // runtime-defined function controls
        .wdata0(wdata0),
        .wdata1(wdata1),
        .waddr(waddr),
        .we(we)
    );
endmodule