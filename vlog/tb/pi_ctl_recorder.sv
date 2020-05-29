`include "mLingua_pwl.vh"

`default_nettype none

module pi_ctl_recorder import const_pack::*; #(
	parameter filename = "pi_ctl.txt"
) (
	input wire logic [Npi-1:0] in [Nout-1:0],
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 'b1) begin
			for (int i=0; i<Nout; i=i+1) begin
				if (i != 0) begin
					$fwrite(fid, ", "); 
				end
				$fwrite(fid, "%0d", in[i]); 
			end

			$fwrite(fid, "\n");
		end
	end

endmodule

`default_nettype wire