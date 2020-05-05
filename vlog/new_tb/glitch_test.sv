`timescale 1fs/1fs

module glitch_test #(
	parameter real freq = 4e9,
	parameter real freq_tol = 0.01,
	parameter real duty = 0.5,
	parameter real width_tol = 40e-12,
	parameter integer min_edges = 100
) (
	input wire logic in,
	input wire logic start,
	input wire logic stop
);
    // testing parameters

	localparam real T = 1.0/freq;
	localparam real T_min = T - width_tol;
	localparam real T_max = T + width_tol;
    localparam real hi_width_min = duty*T - width_tol;
    localparam real hi_width_max = duty*T + width_tol;
    localparam real lo_width_min = (1.0-duty)*T - width_tol;
    localparam real lo_width_max = (1.0-duty)*T + width_tol;

    // internal variables

	real test_start_time, test_stop_time;
	real rising_edge_time, falling_edge_time;
	real delta, ave, period;

	logic test_has_started = 'b0;
	integer num_posedge = 0;

    // test start logic

	always @(posedge start) begin
		if (test_has_started == 'b0) begin
			test_start_time = $realtime/1s;
			rising_edge_time = -1.0;
			falling_edge_time = -1.0;
			test_has_started = 'b1;
			num_posedge = 0;
		end
	end

    // test stop logic

	always @(posedge stop) begin
		if (test_has_started == 'b1) begin
		    // check that the number of positive edges is high enough
		    assert (num_posedge >= min_edges) else begin
		        $error("Number of edges is not large enough: expected at least %0d, got %0d",
		               min_edges, num_posedge);
		    end
		    // check that the average frequency is right
			test_stop_time = $realtime/1s;
			ave = (test_stop_time - test_start_time)/(num_posedge-1);
			assert ((1.0-freq_tol)*T <= ave && ave <= (1.0+freq_tol)*T) else begin
				$error("Input period failure: expected %0e, got %0e", T, ave);
			end

			// flag test as having ended
			test_has_started = 'b0;
		end else begin
			$error("Test has not been started yet.");
		end
	end

    // rising edge logic
    // this is when we can check the period and the *low* width

	always @(posedge in) begin
		if (test_has_started == 'b1) begin
			// check the period
			if (rising_edge_time >= 0) begin
			    period = ($realtime/1s) - rising_edge_time;
			    assert ((T_min <= period) && (period <= T_max)) else begin
					$error("Period violation: expected %0e, got %0e", T, period);
				end
			end
			// check the *low* width
			rising_edge_time = $realtime/1s;
			num_posedge = num_posedge + 1;
			if (falling_edge_time >= 0) begin
				delta = rising_edge_time - falling_edge_time;
				assert ((lo_width_min <= delta) && (delta <= lo_width_max)) else begin
					$error("Negative half-cycle length violation: expected %0e, got %0e",
					       (1.0-duty)*T, delta);
				end
			end
		end
	end

    // falling edge logic
    // this is when we can check the period and the *high* width

	always @(negedge in) begin
		if (test_has_started == 'b1) begin
			// check the period
			if (falling_edge_time >= 0) begin
			    period = ($realtime/1s) - falling_edge_time;
			    assert ((T_min <= period) && (period <= T_max)) else begin
					$error("Period violation: expected %0e, got %0e", T, period);
				end
			end
		    // check *high* width
			falling_edge_time = $realtime/1s;
			if (rising_edge_time >= 0) begin
				delta = falling_edge_time-rising_edge_time;
				assert ((hi_width_min <= delta) && (delta <= hi_width_max)) else begin
					$error("Positive half-cycle length violation: expected %0e, got %0e",
					       duty*T, delta);
				end
			end
		end
	end

endmodule
