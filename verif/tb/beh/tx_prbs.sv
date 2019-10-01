`include "mLingua_pwl.vh"

`default_nettype none

module tx_prbs #(
	parameter real freq=16e9,
	parameter real td=66.2e-12
) (
	output wire logic clk,
	output wire logic out
);

	// Internal signals

	logic rst;

	// TX reset
	
	initial begin
		rst = 'b1;
		#(1ns);
		rst = 'b0;
	end

	// TX clock

	clock #(
		.freq(freq),
		.duty(0.5),
		.td(td)
	) iTXCLK (
		.ckout(clk)
	);

	// TX data

 	prbs21 xprbs (
 		.clk(clk),
 		.rst(rst),
 		.out(out)
 	); 

endmodule

`default_nettype wire
