module bit_aligner #(
	parameter integer width=16,
	parameter integer depth=2
) (
	logc  bit_segment [width*depth-1:0],
	logic [$clog2(width*(depth-1))-1:0] align_pos,
	logic aligned_bits [width-1:0]

);
	initial assert(depth>1);

	integer ii;
	always_comb begin
		for(ii=0; ii<width; ii = ii + 1) begin
			aligned_bits[ii] = bit_segment[ii+align_pos];
		end
	end

endmodule : bit_aligner
