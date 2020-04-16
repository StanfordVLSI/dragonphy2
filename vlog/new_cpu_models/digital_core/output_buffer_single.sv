module output_buffer_single (
    input wire logic in [15:0],
    input wire logic [2:0] ndiv,
    input wire logic rstb,
    input wire logic [3:0] sel,
    input wire logic bypass_div,
    output wire logic outn,
    output wire logic outp
);
    // input mux
    logic mux_o;
    assign mux_o = in[sel];

    // frequency division
    logic div_o;
    sync_divider sync_divider_i (
        .in(mux_o),
        .ndiv(ndiv),
        .rstb(rstb),
        .out(div_o)
    );

    // frequency divider bypass
    logic bypass_o;
    assign bypass_o = (bypass_div == 1'b0) ? mux_o : div_o;

    // single-ended to differential conversion
    assign outn = ~bypass_o;
    assign outp = bypass_o;
endmodule