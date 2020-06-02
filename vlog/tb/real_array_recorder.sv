module real_array_recorder #(
	parameter integer n = 1,
	parameter filename = "real_array.txt"
) (
	input real in [n],
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
	    if (en == 'b1) begin
			for (int i=0; i<n; i=i+1) begin
				if (i != 0) begin
					$fwrite(fid, ", ");
				end
				$fwrite(fid, "%0e", in[i]);
			end
			$fwrite(fid, "\n");
		end
	end

endmodule