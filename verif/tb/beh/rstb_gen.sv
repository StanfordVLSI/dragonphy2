`default_nettype none

module rstb_gen #(
	parameter real width=20e-9
) (
	output var logic rstb
);

	initial begin
		rstb = 1'b0;
		#(width*1s);
		rstb = 1'b1;
	end

endmodule

`default_nettype wire
