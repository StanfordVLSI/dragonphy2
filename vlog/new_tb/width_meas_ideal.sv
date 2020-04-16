module width_meas_ideal (
	input wire logic in,
	output real width
);
	real rise_time=-1;

	always @(posedge in) begin
		rise_time = $realtime / 1s;
	end

	always @(negedge in) begin
	    if (rise_time >= 0) begin
	        width = ($realtime / 1s) - rise_time;
	    end
	end
endmodule

