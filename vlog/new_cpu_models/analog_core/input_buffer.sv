module input_buffer (
	input wire logic inp,
	input wire logic inn,
	input wire logic en,
	input wire logic in_aux,
	input wire logic sel_in,
	input wire logic bypass_div,
	input wire logic [2:0] ndiv,
	input wire logic en_meas,

	output wire logic out,
	output wire logic out_meas
);
    logic amp_out;
    assign amp_out = inp;

    logic mux1_out;
    assign mux1_out = (sel_in == 1'b0) ? amp_out : in_aux;

    logic div2;
    logic ff_out=0;
    always @(posedge mux1_out) begin
        ff_out <= div2;
    end
    assign div2 = ~ff_out;

    logic div_out;
    sync_divider sync_divider_i (
        .in(div2),
        .ndiv(ndiv),
        .rstb(en),
        .out(div_out)
    );

    assign out = (bypass_div == 1'b0) ? div2 : div_out;
    assign out_meas = out & en_meas;
endmodule
