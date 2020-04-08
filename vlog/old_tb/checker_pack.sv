package checker_pack;

	task check_rel_tol(real measured, real expected, real tol);
		real delta;

		delta = tol*expected;
		
		if (delta < 0) begin
			delta = -delta;
		end

		assert (((expected - delta) <= measured) && (measured <= (expected + delta)))
			else $fatal("Got %f, expected %f", measured, expected);
	endtask

	task check_abs_tol(real measured, real expected, real tol);
		real delta;

		assert (((expected - tol) <= measured) && (measured <= (expected + tol)))
			else $fatal("Got %f, expected %f", measured, expected);
	endtask

endpackage