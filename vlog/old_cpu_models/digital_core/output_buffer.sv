`default_nettype none

module output_buffer import const_pack::* ; #(
) (
	input wire bufferend_signals[15:0],
    input wire [3:0] sel_outbuff,
    input wire [3:0] sel_trigbuff,
    input wire en_outbuff,
    input wire en_trigbuff,
    input wire bypass_out_div,
    input wire bypass_trig_div,
    input wire [2:0] Ndiv_outbuff,
    input wire [2:0] Ndiv_trigbuff,

	output wire clock_out_p,
    output wire clock_out_n,
    output wire trigg_out_p,
    output wire trigg_out_n
);

//synopsys translate_off
    // muxes

    logic outbuff;
    assign outbuff = bufferend_signals[sel_outbuff];
    logic trigbuff;
    assign trigbuff = bufferend_signals[sel_trigbuff];

	logic [2:0] Ndiv1;
	logic [2:0] Ndiv2;
	 always @* begin
	if (bypass_out_div) Ndiv1=0;
	else begin
		if (Ndiv_outbuff > 4) Ndiv1 = 1;
		else Ndiv1 = (6-Ndiv_outbuff);
	end
	 
	if (bypass_trig_div) Ndiv2=0;
	else begin
		if (Ndiv_trigbuff > 4) Ndiv2 = 1;
		else Ndiv2 = (6-Ndiv_trigbuff);
	end 
end
    // frequency division

    logic outbuff_div;

    freq_divider #(
        .N(3)
    ) freq_divider_out (
        .cki(outbuff),
        .cko(outbuff_div),
        .ndiv(Ndiv1),
        .rstb(en_outbuff)
    );

    logic trigbuff_div;

    freq_divider #(
        .N(3)
    ) freq_divider_trig (
        .cki(trigbuff),
        .cko(trigbuff_div),
        .ndiv(Ndiv2),
        .rstb(en_trigbuff)
    );

    // output driver

    assign clock_out_p = (en_outbuff == 1'b1) ?  outbuff_div  : 1'b0;
    assign clock_out_n = (en_outbuff == 1'b1) ? ~outbuff_div  : 1'b0;
    assign trigg_out_p = (en_outbuff == 1'b1) ?  trigbuff_div : 1'b0;
    assign trigg_out_n = (en_outbuff == 1'b1) ? ~trigbuff_div : 1'b0;
//synopsys translate_on

endmodule

`default_nettype wire
