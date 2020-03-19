`include "svreal.sv"

module test_chan_model #(
    parameter real in_range=10,
    parameter real out_range=10,
    parameter real dt_range=1e-6
) (
    input real in_,
    output real out,
    input real dt_sig,
    input clk,
    input cke,
    input rst
);
    // wire input
    `MAKE_REAL(in_int, in_range);
    assign `FORCE_REAL(in_, in_int);

    // wire output
    `MAKE_REAL(out_int, out_range);
    assign out = `TO_REAL(out_int);

    // wire dt
    `MAKE_REAL(dt_int, dt_range);
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
        .rst(rst)
    );
endmodule