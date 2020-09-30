`default_nettype none

module sram_recorder import const_pack::*; #(
	parameter filename = "ti_adc.txt"
) (
	input wire logic signed [Nadc-1:0] in [Nti+Nti_rep-1:0],
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
        $shm_open("waves.shm"); $shm_probe("AC");
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 'b1) begin
			for (int i=0; i<Nti+Nti_rep; i=i+1) begin
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
