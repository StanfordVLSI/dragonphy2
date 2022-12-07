`default_nettype none
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
	input wire logic [delay_width+width_width-1:0] flat_codes_delay,
	input wire logic [shiftBitwidth-1:0] shift_index [numChannels-1:0],
	input wire logic disable_product [ffeDepth-1:0][numChannels-1:0],

	input wire logic [delay_width+width_width-1:0] curs_pos,

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

logic signed [codeBitwidth-1:0] flat_code_0;
logic signed [codeBitwidth-1:0] flat_code_1;
logic signed [codeBitwidth-1:0] flat_code_2;
logic signed [codeBitwidth-1:0] flat_code_3;
logic signed [codeBitwidth-1:0] flat_code_4;
logic signed [codeBitwidth-1:0] flat_code_5;
logic signed [codeBitwidth-1:0] flat_code_6;
logic signed [codeBitwidth-1:0] flat_code_7;
logic signed [codeBitwidth-1:0] flat_code_8;
logic signed [codeBitwidth-1:0] flat_code_9;
logic signed [codeBitwidth-1:0] flat_code_10;
logic signed [codeBitwidth-1:0] flat_code_11;
logic signed [codeBitwidth-1:0] flat_code_12;
logic signed [codeBitwidth-1:0] flat_code_13;
logic signed [codeBitwidth-1:0] flat_code_14;
logic signed [codeBitwidth-1:0] flat_code_15;
logic signed [codeBitwidth-1:0] flat_code_16;
logic signed [codeBitwidth-1:0] flat_code_17;
logic signed [codeBitwidth-1:0] flat_code_18;
logic signed [codeBitwidth-1:0] flat_code_19;
logic signed [codeBitwidth-1:0] flat_code_20;
logic signed [codeBitwidth-1:0] flat_code_21;
logic signed [codeBitwidth-1:0] flat_code_22;
logic signed [codeBitwidth-1:0] flat_code_23;
logic signed [codeBitwidth-1:0] flat_code_24;
logic signed [codeBitwidth-1:0] flat_code_25;
logic signed [codeBitwidth-1:0] flat_code_26;
logic signed [codeBitwidth-1:0] flat_code_27;
logic signed [codeBitwidth-1:0] flat_code_28;
logic signed [codeBitwidth-1:0] flat_code_29;
logic signed [codeBitwidth-1:0] flat_code_30;
logic signed [codeBitwidth-1:0] flat_code_31;

assign flat_code_0 = flat_codes[0];
assign flat_code_1 = flat_codes[1];
assign flat_code_2 = flat_codes[2];
assign flat_code_3 = flat_codes[3];
assign flat_code_4 = flat_codes[4];
assign flat_code_5 = flat_codes[5];
assign flat_code_6 = flat_codes[6];
assign flat_code_7 = flat_codes[7];
assign flat_code_8 = flat_codes[8];
assign flat_code_9 = flat_codes[9];
assign flat_code_10 = flat_codes[10];
assign flat_code_11 = flat_codes[11];
assign flat_code_12 = flat_codes[12];
assign flat_code_13 = flat_codes[13];
assign flat_code_14 = flat_codes[14];
assign flat_code_15 = flat_codes[15];
assign flat_code_16 = flat_codes[16];
assign flat_code_17 = flat_codes[17];
assign flat_code_18 = flat_codes[18];
assign flat_code_19 = flat_codes[19];
assign flat_code_20 = flat_codes[20];
assign flat_code_21 = flat_codes[21];
assign flat_code_22 = flat_codes[22];
assign flat_code_23 = flat_codes[23];
assign flat_code_24 = flat_codes[24];
assign flat_code_25 = flat_codes[25];
assign flat_code_26 = flat_codes[26];
assign flat_code_27 = flat_codes[27];
assign flat_code_28 = flat_codes[28];
assign flat_code_29 = flat_codes[29];
assign flat_code_30 = flat_codes[30];
assign flat_code_31 = flat_codes[31];

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
`default_nettype wire