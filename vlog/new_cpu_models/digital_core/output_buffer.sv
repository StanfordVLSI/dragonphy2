module output_buffer (
    input wire logic bufferend_signals [15:0],
    input wire logic [3:0] sel_outbuff,
    input wire logic [3:0] sel_trigbuff,
    input wire logic en_outbuff,
    input wire logic en_trigbuff,
    input wire logic bypass_out_div,
    input wire logic bypass_trig_div,
    input wire logic [2:0] Ndiv_outbuff,
    input wire logic [2:0] Ndiv_trigbuff,
    output wire logic clock_out_p,
    output wire logic clock_out_n,
    output wire logic trigg_out_p,
    output wire logic trigg_out_n
);
    output_buffer_single obs0 (
        .in(bufferend_signals),
        .ndiv(Ndiv_outbuff),
        .rstb(en_outbuff),
        .sel(sel_outbuff),
        .bypass_div(bypass_out_div),
        .outn(clock_out_n),
        .outp(clock_out_p)
    );
    output_buffer_single obs1 (
        .in(bufferend_signals),
        .ndiv(Ndiv_trigbuff),
        .rstb(en_trigbuff),
        .sel(sel_trigbuff),
        .bypass_div(bypass_trig_div),
        .outn(trigg_out_n),
        .outp(trigg_out_p)
    );
endmodule