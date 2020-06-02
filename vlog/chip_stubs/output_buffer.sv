module output_buffer (
    input bufferend_signals [15:0],
    input [3:0] sel_outbuff,
    input [3:0] sel_trigbuff,
    input en_outbuff,
    input en_trigbuff,
    input bypass_out_div,
    input bypass_trig_div,
    input [2:0] Ndiv_outbuff,
    input [2:0] Ndiv_trigbuff,
    output clock_out_p,
    output clock_out_n,
    output trigg_out_p,
    output trigg_out_n
);
endmodule