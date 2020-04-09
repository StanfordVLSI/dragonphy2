`default_nettype none

module real_recorder #(
	parameter filename = "real.txt"
) (
	input real in,
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 'b1) begin
			$fwrite(fid, "%0e\n", in); 
		end
	end

endmodule

`default_nettype wire