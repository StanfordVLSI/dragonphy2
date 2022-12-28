`include "mLingua_pwl.vh"

`default_nettype none

module diff_tx_driver #(
	parameter real vh = 0.4,
	parameter real vl = 0.1,
	parameter real tr = 10e-12,
	parameter integer sym_bitwidth = 1
) (
	input wire logic [sym_bitwidth-1:0] in,
	output pwl out_p,
	output pwl out_n
);

	sym2pwl #(
		.vh(vh),
		.vl(vl),
		.tr(tr),
		.tf(tr),
		.sym_bitwidth(sym_bitwidth)
	) dac_p (
		.in(in),
		.out(out_p)
	);

	sym2pwl #(
		.vh(vh),
		.vl(vl),
		.tr(tr),
		.tf(tr),
		.sym_bitwidth(sym_bitwidth)
	) dac_n (
		.in(~in),
		.out(out_n)
	);

endmodule

`default_nettype wire
