`timescale 1fs/1fs

`default_nettype none

module glitch_test #(
	parameter real freq = 4e9,
	parameter real freq_tol = 0.01,
	parameter real duty = 0.5,
	parameter real duty_tol = 0.01
) (
	input wire logic in,
	input wire logic start,
	input wire logic stop
);

	localparam real T = 1.0/freq;

	real test_start_time, test_stop_time;
	real rising_edge_time, falling_edge_time;
	real delta, ave;

	logic test_has_started = 'b0;
	integer num_posedge = 0;

	always @(posedge start) begin
		if (test_has_started == 'b0) begin
			test_start_time = $realtime/1s;
			rising_edge_time = -1.0;
			falling_edge_time = -1.0;
			test_has_started = 'b1;
			num_posedge = 0;
		end
	end

	always @(posedge stop) begin
		if (test_has_started == 'b1) begin
			test_stop_time = $realtime/1s;
			ave = (test_stop_time - test_start_time)/(num_posedge-1);
			assert ((1.0-freq_tol)*T <= ave && ave <= (1.0+freq_tol)*T) else begin
				$display("Input period failure: expected %e, got %e", T, ave);
				#(1ns); // delay for easier waveform viewing
				$fatal;
			end
			test_has_started = 'b0;
		end else begin
			$display("Test has not been started yet.");
			$fatal;
		end
	end

	always @(posedge in) begin
		if (test_has_started == 'b1) begin
			rising_edge_time = $realtime/1s;
			num_posedge = num_posedge + 1;
			if (falling_edge_time >= 0) begin
				delta = rising_edge_time-falling_edge_time;
				assert ((1.0-duty_tol)*(1.0-duty)*T <= delta && delta <= (1+duty_tol)*(1.0-duty)*T) else begin
					$display("Negative half-cycle length violation: expected %e, got %e", (1.0-duty)*T, delta);
					#(1ns); // delay for easier waveform viewing
					$fatal;
				end
			end
		end
	end

	always @(negedge in) begin
		if (test_has_started == 'b1) begin
			falling_edge_time = $realtime/1s;
			if (rising_edge_time >= 0) begin
				delta = falling_edge_time-rising_edge_time;
				assert ((1.0-duty_tol)*duty*T <= delta && delta <= (1+duty_tol)*duty*T) else begin
					$display("Positive half-cycle length violation: expected %e, got %e", duty*T, delta);
					#(1ns); // delay for easier waveform viewing
					$fatal;
				end
			end
		end
	end

endmodule

`default_nettype wire
