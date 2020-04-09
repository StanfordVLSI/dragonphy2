`default_nettype none

module oneshot_memory import const_pack::*; (
    input wire logic clk,
    input wire logic rstb,
    input wire logic signed [Nadc-1:0] in_data [Nti+Nti_rep-1:0],

    input wire logic in_start_write,

    input wire logic [N_mem_addr-1:0] in_addr,

    output wire logic signed [Nadc-1:0] out_data [Nti+Nti_rep-1:0],
    output wire logic [N_mem_addr-1:0] addr
);

	localparam [N_mem_addr-1:0] max_addr = {N_mem_addr{1'b1}};

	// SRAM address muxing

	logic WEB;
	logic [N_mem_addr-1:0] write_addr;

	assign addr = (WEB == 1'b0) ? write_addr : in_addr;

	// SRAM data I/O

	logic [(Nti+Nti_rep)*Nadc-1:0] concat_data_in;
	logic [(Nti+Nti_rep)*Nadc-1:0] concat_data_out;

	genvar j;
	generate
	    for (j=0; j<(Nti+Nti_rep); j=j+1) begin
	        assign concat_data_in[(j+1)*Nadc-1:j*Nadc] = in_data[j];
	        assign out_data[j] = concat_data_out[(j+1)*Nadc-1:j*Nadc];
	    end
	endgenerate

	// main state machine

	typedef enum logic [1:0] {WAIT_FOR_WRITE, WRITE_IN_PROGRESS, WRITE_DONE} ctrl_state_t;
	ctrl_state_t ctrl_state;

	always @(posedge clk) begin
		if (rstb == 1'b0) begin
			WEB <= 1'b1;
			write_addr <= 'd0;
			ctrl_state <= WAIT_FOR_WRITE;
		end else begin
			case (ctrl_state)
				WAIT_FOR_WRITE : begin
					WEB <= (in_start_write == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= 'd0;
					ctrl_state <= (in_start_write == 1'b1) ? WRITE_IN_PROGRESS : WAIT_FOR_WRITE;
				end		 
				WRITE_IN_PROGRESS : begin
					WEB <= (write_addr == max_addr) ? 1'b1 : 1'b0;
					write_addr <= (write_addr == max_addr) ? max_addr : write_addr + 'd1;
					ctrl_state <= (write_addr == max_addr) ? WRITE_DONE : WRITE_IN_PROGRESS;
				end
				WRITE_DONE : begin
					WEB <= 1'b1;
					write_addr <= max_addr;
					ctrl_state <= (in_start_write == 1'b0) ? WAIT_FOR_WRITE : WRITE_DONE;
				end
				default : begin
					// same as WAIT_FOR_WRITE
					WEB <= (in_start_write == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= 'd0;
					ctrl_state <= (in_start_write == 1'b1) ? WRITE_IN_PROGRESS : WAIT_FOR_WRITE;
				end	 
			endcase
		end
	end

	// instantiate SRAM
	sram #(
		.ADR_BITS(N_mem_addr),
		.DAT_BITS((Nti+Nti_rep)*Nadc)
	) sram_i (
		.CLK(clk),
		.CEB(1'b0),
		.WEB(WEB),
		.A(addr),
		.D(concat_data_in),
		.Q(concat_data_out)
	);

endmodule

`default_nettype wire
