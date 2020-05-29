package checker_pack;

	task check_rel_tol(real measured, real expected, real tol);
		real delta;

		delta = tol*expected;
		
		if (delta < 0) begin
			delta = -delta;
		end

		assert (((expected - delta) <= measured) && (measured <= (expected + delta)))
			else $error("Got %0e, expected %0e", measured, expected);
	endtask

	task check_abs_tol(real measured, real expected, real tol);
		real delta;

		assert (((expected - tol) <= measured) && (measured <= (expected + tol)))
			else $error("Got %0e, expected %0e", measured, expected);
	endtask

endpackage