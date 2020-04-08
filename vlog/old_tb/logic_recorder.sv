`default_nettype none

module logic_recorder #(
	parameter integer n = 1,
	parameter filename = "logic.txt"
) (
	input wire logic [n-1:0] in,
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 'b1) begin
			$fwrite(fid, "%0d\n", in); 
		end
	end

endmodule

`default_nettype wire