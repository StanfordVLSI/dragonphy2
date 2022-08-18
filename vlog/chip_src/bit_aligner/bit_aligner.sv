module bit_aligner #(
	parameter integer width=16,
	parameter integer depth=2,
    parameter integer delay_width=4,
    parameter integer width_width=4
) (
	input logic bit_segment [width*depth-1:0],
	input logic [delay_width + width_width-1:0] bit_segment_delay,
	input logic [$clog2(width*(depth-1))-1:0] align_pos,
	output logic aligned_bits [width-1:0],
	output logic [delay_width + width_width-1:0] aligned_bits_delay

);
	initial assert(depth>1);

	assign aligned_bits_delay = bit_segment_delay + (width*(depth-1) - align_pos);

	integer ii;
	always_comb begin
		for(ii=0; ii<width; ii = ii + 1) begin
			aligned_bits[ii] = bit_segment[ii+align_pos];
		end
	end

endmodule : bit_aligner
