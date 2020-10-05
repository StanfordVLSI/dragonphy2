`include "mLingua_pwl.vh"

`default_nettype none

module diff_channel #(
	parameter channel_type = "simple",
	parameter real etol = 0.001,  // error tolerance of PWL approximation
	parameter real tau = -1
) (
	input pwl in_p,
	input pwl in_n,
	output pwl out_p,
	output pwl out_n
);

	generate
	if (channel_type == "simple") begin
		channel_simple #(
            .etol(etol),
		    .tau(tau)
		) channel_p (
			.in(in_p),
			.out(out_p)
		);
		channel_simple #(
            .etol(etol),
		    .tau(tau)
		) channel_n (
			.in(in_n),
			.out(out_n)
		);
	end else begin
		initial begin
			$error("Invalid channel type: %s", channel_type);
		end
	end
	endgenerate

endmodule

`default_nettype wire
