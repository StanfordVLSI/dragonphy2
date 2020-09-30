// simple model used for performance comparison with emulation

module output_buffer (
    input [15:0] bufferend_signals,
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

    assign clock_out_p = 1'b0;
    assign clock_out_n = 1'b0;
    assign trigg_out_p = 1'b0;
    assign trigg_out_n = 1'b0;

endmodule