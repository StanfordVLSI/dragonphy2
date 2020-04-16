`include "mLingua_pwl.vh"

`default_nettype none

module rx_input_recorder #(
	parameter filename = "rx_input.txt"
) (
	input pwl in_p,
	input pwl in_n,
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 1'b1) begin
			$fwrite(fid, "%e\n", in_p.a-in_n.a);
		end
	end

endmodule

`default_nettype wire