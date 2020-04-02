
module delay_meas_ideal (
	input wire logic ref_in,
	input wire logic in,
	output real delay 
);

	`get_timeunit

	logic start;
	real t0, t1;

	initial begin
		start = 1'b0;
		delay = 0.0;
	end

	// make sure tdi > tout
	always @(posedge ref_in) begin
		start = 1'b1;
		t0 = `get_time;
	end

	always @(posedge in) begin
		t1 = `get_time;
		if (start == 1'b1) begin
			delay = t1- t0;
		end
	end

endmodule

