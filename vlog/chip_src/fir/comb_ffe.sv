module comb_ffe #(
	parameter integer codeBitwidth=8,
	parameter integer weightBitwidth=11,
	parameter integer resultBitwidth=8,
	parameter integer shiftBitwidth=5,
	parameter integer ffeDepth=5,
	parameter integer numChannels=16,
	parameter integer numBuffers=2,
	parameter integer t0_buff=1,
    parameter integer delay_width=4,
    parameter integer width_width=4
) (
	input wire logic signed [weightBitwidth-1:0] weights [ffeDepth-1:0][numChannels-1:0],
	input wire logic signed [codeBitwidth-1:0] flat_codes [numBuffers*numChannels-1:0],
	input logic [delay_width+width_width-1:0] flat_codes_delay,
	input wire logic [shiftBitwidth-1:0] shift_index [numChannels-1:0],
	input wire logic disable_product [ffeDepth-1:0][numChannels-1:0],

	input logic [delay_width+width_width-1:0] curs_pos,

	output logic signed [resultBitwidth-1:0] estimated_bits [numChannels-1:0],
	output logic [delay_width+width_width-1:0] estimated_bits_delay

);

// synthesis translate_off
assign estimated_bits_delay = flat_codes_delay + curs_pos;
// synthesis translate_on
localparam productBitwidth   = codeBitwidth + weightBitwidth;
localparam sumBitwidth	 = $clog2(ffeDepth) + productBitwidth;
localparam idx = t0_buff * numChannels;

logic signed [sumBitwidth-1:0] result [numChannels-1:0];
logic signed [productBitwidth-1:0] product [ffeDepth-1:0][numChannels-1:0];

logic signed [codeBitwidth-1:0]   mux_codes   [ffeDepth-1:0][numChannels-1:0];
logic signed [weightBitwidth-1:0] mux_weights [ffeDepth-1:0][numChannels-1:0];

genvar gi;
generate
	for(gi=0; gi<numChannels; gi=gi+1) begin
		always_comb begin 
			integer ii;
			result[gi] = 0;
			for(ii=0; ii<ffeDepth; ii=ii+1) begin
				//The Flat Buffer is ranged from 0 (oldest) to numChannels*ffeDepth (newest)
				//The weights need to be used in reverse order for the first weight (0) to touch the newest code (cp_offset + ffeDepth)
				mux_weights[ii][gi] = disable_product[ii][gi] ? 0 : weights[ii][gi]; 
				mux_codes[ii][gi]   = disable_product[ii][gi] ? 0 : flat_codes[idx - ii + gi];
				//Seperate product and summation for later potential optimizations ;)
				//product[ii][gi] = weights[ffeDepth - ii - 1][gi]*flat_codes[cursor_pos_offset + ii + gi];
				product[ii][gi]   	= mux_weights[ii][gi] * mux_codes[ii][gi];
				result[gi] 			= result[gi] + product[ii][gi];
			end
			estimated_bits[gi] = (result[gi] >>> shift_index[gi]);
		end
	end
endgenerate

endmodule : comb_ffe