module error_tracker #(
	parameter integer width=16,
	parameter integer error_bitwidth=8,
	parameter integer addrwidth= 12
)(
	input logic trigger,
	
	input logic signed [error_bitwidth-1:0] errors [width*3-1:0],
	input logic [width*3-1:0] prbs_flags,
	input logic [width*3-1:0] bitstream,
	input logic [1:0] sd_flags [width*3-1:0],

	input logic clk,
	input logic rstb,

	error_tracker_debug_intf.tracker errt_dbg_intf_i
);

	localparam [addrwidth-1:0] max_addr = {addrwidth{1'b1}};
	localparam halfwidth = 8;// width >> 1;

	typedef enum logic [1:0] {READY, STORE, DONE} state_t;
	state_t state, next_state;
	logic [addrwidth-1:0] write_addr;
	logic [addrwidth-1:0] addr;
	logic [1:0] store_count;
	logic store_finished;
	logic enabled;
	logic WEB;

	logic [143:0] next_data_frames [3:0];
	logic [143:0] data_frames [3:0];
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
		assign errt_dbg_intf_i.output_data_frame[4] = {output_data_frame[143:128], {16{1'b0}}};
		//Concatenate and store the error values
		for(gi=0; gi < 3; gi = gi + 1) begin
			for(gj = 0; gj < width; gj = gj + 1) begin
				assign next_data_frames[gi][(gj+1)*error_bitwidth-1:gj*error_bitwidth] = $unsigned(errors[gj + width*gi]);
			end
		end
		//Concatenate and store the PRBS flags, the bistream and the sliding detector outputs
		assign next_data_frames[3][width*3-1:0] 	     = prbs_flags;
		assign next_data_frames[3][width*6-1:width*3] = bitstream;
		for(gi = 0; gi < width + halfwidth ; gi = gi + 1 ) begin
			assign next_data_frames[3][width*6 + (gi+1) * 2 - 1: width*6 + gi*2] = sd_flags[gi + halfwidth];
		end
	endgenerate

	assign addr = !(state == DONE) ? write_addr : read_addr;
	assign at_memory_end = (write_addr == max_addr);
	assign store_finished = (store_count == 2'b11);
	assign enabled = (enable == 1'b1);

	//Input Data Frame is always the data_frame attached to the current store count
	assign input_data_frame = data_frames[store_count];
	assign errt_dbg_intf_i.number_stored_frames = write_addr;

	always_ff @(posedge clk or negedge rstb) begin 
		integer ii;
		if(~rstb) begin
			store_count <= 0;
			state 		<= READY;
			write_addr  <= 0;
			WEB 		<= 1'b1;
			for(ii = 0; ii < 4; ii = ii + 1) begin
				data_frames[ii] <= 0;
			end
		end else begin
			case (state)
				READY : begin
					WEB 	    <= (trigger == 1'b1) ? 1'b0 : 1'b1;
					state 	    <= (trigger == 1'b1) ? STORE : (read == 1'b1 ? DONE : READY);
					for(ii = 0; ii < 4; ii = ii + 1) begin
						data_frames[ii] <= next_data_frames[ii];
					end
				end		 
				STORE : begin
					WEB 	    <= at_memory_end ? 1'b1  	: store_finished ? 1'b1  : 1'b0  ;
					store_count <= at_memory_end ? 2'b00 	: store_finished ? 2'b00 : store_count + 'd1;
					write_addr  <= at_memory_end ? max_addr : write_addr + 1'b1;
					state 	    <= at_memory_end ? DONE 	: (store_finished && !(trigger == 1'b1)) ? (read == 1'b1 ? DONE : READY) : STORE ;
				end
				DONE : begin
					WEB		    <= 1'b1;
					write_addr  <= enabled ? 'd0 : write_addr;
					store_count <= enabled ? 2'b00 : store_count;
					state       <= enabled ? READY : DONE;
				end
				default : begin
					// same as WAIT_FOR_WRITE
					WEB <= (trigger == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= 'd0;
					store_count <= 2'b00;
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

endmodule : error_tracker