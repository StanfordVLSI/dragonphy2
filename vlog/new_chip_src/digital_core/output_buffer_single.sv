module output_buffer_single (
    output outn,
    output outp,
    input bypass_div,
    input [15:0] in,
    input [2:0] ndiv,
    input rstb,
    input [3:0] sel
);
    // internal signals
    wire net10, net9, net010;

    mux16 imux16_dont_touch (
        .out(net10),
        .in(in),
        .sel(sel)
    );

    sync_divider isync_divider_dont_touch (
        .out(net9),
        .in(net10),
        .ndiv(ndiv),
        .rstb(rstb)
    );

    single_to_diff_buff isingle_to_diff_buff_dont_touch (
        .OUTN(outn),
        .OUTP(outp),
        .IN(net010)
    );

    mux imux_dont_touch (
        .in0(net9),
        .in1(net10),
        .sel(bypass_div),
        .out(net010)
    );
endmodule

