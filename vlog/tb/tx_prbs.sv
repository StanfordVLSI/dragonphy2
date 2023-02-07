`include "mLingua_pwl.vh"

`default_nettype none

module tx_prbs #(
	parameter real freq=16e9,
	parameter integer sym_bitwidth = 1,
	parameter real td=66.2e-12
) (
	output wire logic clk,
	output wire logic [sym_bitwidth-1:0] out
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

	genvar gi;
	generate 
		for(gi = 0; gi < sym_bitwidth; gi = gi + 1) begin
			adv_prbs21  #(
				.init('1 - gi)
			) xprbs (
				.clk(clk),
				.rst(rst),
				.out(out[gi])
			); 
		end
	endgenerate 
endmodule

`default_nettype wire
