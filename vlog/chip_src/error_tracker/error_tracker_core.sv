module error_tracker_core #(
	parameter integer width=16,
	parameter integer error_bitwidth=8,
	parameter integer addrwidth= 12,
	parameter integer flag_width=4,
	parameter integer sym_bitwidth=2
)(
	input logic trigger,
	
	input logic signed [error_bitwidth-1:0]      errors [width*4-1:0],
	input logic                                  prbs_flags [width*sym_bitwidth*4-1:0],
	input logic signed [(2**sym_bitwidth-1)-1:0] symstream [width*4-1:0],
	input logic [flag_width-1:0]                 sd_flags [width*4-1:0],

	input logic clk,
	input logic rstb,

	error_tracker_debug_intf.tracker errt_dbg_intf_i
);

	localparam integer sw = ((2**sym_bitwidth)-1);
	localparam [addrwidth-1:0] max_addr = {addrwidth{1'b1}};
	localparam halfwidth = 8;
	logic [1:0] decoded_symbols [4*width-1:0];

	typedef enum logic [1:0] {READY, STORE, DONE} state_t;
	state_t state, next_state;
	logic [addrwidth-1:0] write_addr;
	logic [addrwidth-1:0] addr;
	logic [2:0] store_count;
	logic store_finished;
    logic at_memory_end;
	logic enabled;
	logic WEB;

	logic [143:0] next_data_frames [7:0];
	logic [143:0] data_frames [7:0];
	logic [143:0] input_data_frame;
	logic [143:0] output_data_frame;

	logic [addrwidth-1:0] read_addr;
	logic read;
	logic enable;

	assign read_addr = errt_dbg_intf_i.addr;
	assign read 	 = errt_dbg_intf_i.read;
	assign enable 	 = errt_dbg_intf_i.enable;

	genvar gi, gj;
	generate
		//Chunk data into 32 bit blocks (requires 5 reads vs 18! 3x faster :))
		for(gi=0; gi < 4; gi = gi + 1) begin
			assign errt_dbg_intf_i.output_data_frame[gi] = output_data_frame[(gi+1)*32 -1: gi*32];
		end
		assign errt_dbg_intf_i.output_data_frame[4] = {{16{1'b1}}, output_data_frame[143:128]};

		//Concatenate and store the error values
		for(gi=0; gi < 4; gi = gi + 1) begin
			for(gj = 0; gj < width; gj = gj + 1) begin
				assign next_data_frames[gi][(gj+1)*error_bitwidth-1:gj*error_bitwidth] = $unsigned(errors[gj + width*gi]);
			end
		end

		//Concatenate and store the PRBS flags, the bistream and the sliding detector outputs - 64, 16*2*4 = 128
		for(gi = 0; gi < width*sym_bitwidth*4; gi = gi + 1) begin
			assign next_data_frames[4][gi] = prbs_flags[gi];
		end

		//Concatenate and store the symbol stream - 64, 4*16*2 = 128

		for(gi = 0; gi < width*4; gi = gi +1) begin
			always_comb begin
                unique case (symstream[gi])
                    3: begin 
                        decoded_symbols[gi] = 2'b10;
                    end
                    1: begin 
                        decoded_symbols[gi] = 2'b11;
                    end
                    -1: begin 
                        decoded_symbols[gi] = 2'b01;
                    end
                    -3: begin 
                        decoded_symbols[gi] = 2'b00;
                    end
                endcase
			end
			assign next_data_frames[5][sym_bitwidth*(gi+1)-1:sym_bitwidth*gi] = decoded_symbols[gi];
		end


		//Concatenate and store the sliding detector flags - 32, 2*16*4 = 128
		for(gi = 0; gi < 2*width; gi = gi + 1 ) begin
			assign next_data_frames[6][4*(gi+1)-1: 4*gi] 	 = sd_flags[gi];
		end
		//Concatenate and store the sliding detector flags - 32, 2*16*4 = 128
		for(gi = 0; gi < 2*width; gi = gi + 1 ) begin
			assign next_data_frames[7][4*(gi+1)-1: 4*gi] 	 = sd_flags[gi+2*width];
		end
	endgenerate

	assign addr 			= !(state == DONE) ? write_addr : read_addr;
	assign at_memory_end 	= (write_addr == max_addr);
	assign store_finished 	= (store_count == 3'b111);
	assign enabled 			= (enable == 1'b1);

	//Input Data Frame is always the data_frame attached to the current store count
	assign input_data_frame                     = data_frames[store_count];
	assign errt_dbg_intf_i.number_stored_frames = write_addr;

	always_ff @(posedge clk or negedge rstb) begin 
		integer ii;
		if(~rstb) begin
			store_count <= 0;
			state 		<= READY;
			write_addr  <= 0;
			WEB 		<= 1'b1;
			for(ii = 0; ii < 8; ii = ii + 1) begin
				data_frames[ii] <= 0;
			end
		end else begin
			case (state)
				READY : begin
					WEB 	    <= (trigger == 1'b1) ? 1'b0 : 1'b1;
					state 	    <= (trigger == 1'b1) ? STORE : (read == 1'b1 ? DONE : READY);
					for(ii = 0; ii < 8; ii = ii + 1) begin
						data_frames[ii] <= next_data_frames[ii];
					end
				end		 
				STORE : begin
					WEB 	    <= at_memory_end ? 1'b1  	: store_finished ? 1'b1  : 1'b0  ;
					store_count <= at_memory_end ? 3'b000 	: store_finished ? 3'b000 : store_count + 'd1;
					write_addr  <= at_memory_end ? max_addr : write_addr + 1'b1;
					state 	    <= at_memory_end ? DONE 	: (store_finished && !(trigger == 1'b1)) ? (read == 1'b1 ? DONE : READY) : STORE ;
				end
				DONE : begin
					WEB		    <= 1'b1;
					write_addr  <= enabled ? 'd0 : write_addr;
					store_count <= enabled ? 3'b000 : store_count;
					state       <= enabled ? READY : DONE;
				end
				default : begin
					// same as WAIT_FOR_WRITE
					WEB <= (trigger == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= 'd0;
					store_count <= 3'b000;
					state <= (trigger == 1'b1) ? STORE : READY;
				end	 
			endcase
		end
	end


	// instantiate SRAM
	sram #(
		.ADR_BITS(addrwidth),
		.DAT_BITS(144)
	) sram_i (
		.CLK(clk),
		.CEB(1'b0),
		.WEB(WEB),
		.A(addr),
		.D(input_data_frame),
		.Q(output_data_frame)
	);

endmodule : error_tracker_core
