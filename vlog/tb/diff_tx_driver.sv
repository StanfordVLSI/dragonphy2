`include "mLingua_pwl.vh"

`default_nettype none

module diff_tx_driver #(
	parameter real vh = 0.4,
	parameter real vl = 0.1,
	parameter real tr = 10e-12
) (
	input wire logic in,
	output pwl out_p,
	output pwl out_n
);

	bit2pwl #(
		.vh(vh),
		.vl(vl),
		.tr(tr),
		.tf(tr)
	) dac_p (
		.in(in),
		.out(out_p)
	);

	bit2pwl #(
		.vh(vh),
		.vl(vl),
		.tr(tr),
		.tf(tr)
	) dac_n (
		.in(~in),
		.out(out_n)
	);

endmodule

`default_nettype wire
