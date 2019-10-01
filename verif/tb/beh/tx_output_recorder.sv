`default_nettype none

module tx_output_recorder #(
	parameter filename = "tx_output.txt"
) (
	input wire logic in,
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 'b1) begin
			$fwrite(fid, "%b\n", in);   
		end
	end

endmodule

`default_nettype wire