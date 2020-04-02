`include "mLingua_pwl.vh"

`default_nettype none

module channel_simple #(
	parameter real etol = 0.001,		// error tolerance of PWL approximation
	parameter real baud_rate = 16e9,	// communication baud rate
	parameter real rel_speed = 1 		// higher number is faster
) (
	input pwl in,
	output pwl out
);

	localparam real tau = 1.0/(rel_speed*baud_rate);

	localparam real M_PI = 3.141592653589793;
	localparam real fp = 1.0/(2.0*M_PI*tau);

	pwl_filter_real_p1 #(
		.etol(etol),
		.en_filter('b1)
	) filter_i (
		.fp(fp),
		.in(in),
		.out(out)
	);

endmodule

`default_nettype wire
