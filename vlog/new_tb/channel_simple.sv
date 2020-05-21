`include "mLingua_pwl.vh"

`default_nettype none

module channel_simple #(
	parameter real etol = 0.001,		// error tolerance of PWL approximation
	parameter real baud_rate = 16e9,	// communication baud rate
	parameter real rel_speed = 1, 		// higher number is faster
	parameter real tau = -1
) (
	input pwl in,
	output pwl out
);
    // calculate angular frequency
    localparam real omega = (tau != -1) ? (1.0/tau) : (1.0/(rel_speed*baud_rate));

    // convert to Hz
	localparam real fp = omega/(2.0*3.141592653589793);

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
