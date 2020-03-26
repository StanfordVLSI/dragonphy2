

/***********
* template made quickly by Daniel
* For demoing the rx with a slicer
***********/

module rx_cmp (
	`input_pwl in_,
	`output reg out
);

real slice_point = 0.626897651933;
real in_real;

pwl2real converter(
	.in(in_),
	.out(out)
);

always @(*) begin
	out <= in_real < slice_point;
end

endmodule
