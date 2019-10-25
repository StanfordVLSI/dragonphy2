/***********
* template made quickly by Daniel
* For demoing the rx with a slicer
***********/

module rx_cmp (
	`input_pwl in_,
	`output reg out
);

real slice_point = $$get_lm_equation('test1', 'slice_point');
real in_real;

pwl2real converter(
	.in(in_),
	.out(out)
);

always @(*) begin
	out <= in_real < slice_point;
end

endmodule
