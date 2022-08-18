module flatten_buffer_slice #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer buff_depth  = 5,
	parameter integer slice_depth = 3,
	parameter integer start		  = 0,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
	buffer,
	buffer_delay,
	flat_slice,
	flat_slice_delay
);


	input wire logic [bitwidth-1:0] buffer [numChannels-1:0][buff_depth:0];
	input logic [delay_width+width_width-1:0] buffer_delay[buff_depth:0];
	output logic [bitwidth-1:0] flat_slice [numChannels*(slice_depth+1)-1:0];
	output logic [delay_width+width_width-1:0] flat_slice_delay;

	logic [bitwidth-1:0] buffer_slice [numChannels-1:0][slice_depth:0];
	logic [delay_width+width_width-1:0] buffer_slice_delay [slice_depth:0];

genvar gi, gj;
generate

	for(gi=0; gi < slice_depth+1; gi=gi+1) begin
		for(gj=0; gj<numChannels; gj=gj+1) begin
			assign buffer_slice[gj][gi] = buffer[gj][gi + start]; 
		end
		assign buffer_slice_delay[gi] = buffer_delay[gi+start];
	end
endgenerate

flatten_buffer #(
	.numChannels(numChannels),
	.bitwidth   (bitwidth),
	.depth      (slice_depth)
) flat_buff_i (
	.buffer     (buffer_slice),
	.buffer_delay ( buffer_slice_delay),
	.flat_buffer(flat_slice),
	.flat_buffer_delay(flat_slice_delay)
);

endmodule : flatten_buffer_slice
