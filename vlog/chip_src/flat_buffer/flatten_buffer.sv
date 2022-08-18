module flatten_buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth    	  = 5,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
	buffer,
	buffer_delay,
	flat_buffer,
	flat_buffer_delay
);


		input wire logic [bitwidth-1:0] buffer [numChannels-1:0][depth:0];
		input logic [delay_width+width_width-1:0] buffer_delay[depth:0];
		output logic [bitwidth-1:0] flat_buffer [numChannels*(depth+1)-1:0];
		output logic [delay_width+width_width-1:0] flat_buffer_delay;

// synthesis translate_off
assign flat_buffer_delay = buffer_delay[0];
// synthesis translate_on
genvar gi, gj;
generate 
	for(gj=0; gj<numChannels; gj=gj+1) begin
		for(gi=0; gi<depth+1; gi=gi+1) begin
			assign flat_buffer[(depth - gi)*numChannels + gj] = buffer[gj][gi];
		end
	end
endgenerate

endmodule : flatten_buffer