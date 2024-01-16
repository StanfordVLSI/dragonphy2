module trig_tracker #(
    parameter integer bitwidth = 8,
    parameter integer counter_bitwidth = 10,
    parameter integer memory_addr_width = 10
) (
    input logic clk,
    input logic rstb,

    input logic signed [bitwidth-1:0] in,
    input logic trigger,

    input wire logic [memory_addr_width-1:0] in_addr,

    output wire logic [counter_bitwidth+2-1:0] mem_data_out
);

	localparam [memory_addr_width-1:0] max_addr = {memory_addr_width{1'b1}};

    // Data Change Event Detection
    logic signed [1:0] data_event;
    logic signed [bitwidth-1:0] in_prev;

    always_ff @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin
            in_prev <= 0;
        end else begin
            in_prev <= in;
        end
    end

    always_comb begin
        if(in > in_prev) begin
            data_event = 2'b11;
        end else if (in < in_prev) begin
            data_event = 2'b10;
        end else begin
            data_event = 2'b00;
        end
    end

    // Counter that resets on trigger
    logic [counter_bitwidth-1:0] counter, counter_next;
    logic counter_overflow;

    assign counter_overflow = (counter == {counter_bitwidth{1'b1}});
    assign counter_next = (counter_overflow == 1'b1) ? 0 : counter + 1;

    always_ff @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin
            counter <= 0;
        end else begin
            if (data_event[1]) begin
                counter <= 0;
            end else begin
                counter <= counter_next;
            end
        end
    end

    // Memory Trigger

    logic mem_write_trigger;

    assign mem_write_trigger = counter_overflow | data_event[1];

    // Memory Storage and Control

    logic [counter_bitwidth+2-1:0] mem_data_in;
    logic [counter_bitwidth+2-1:0] mem_data_init;
    logic [counter_bitwidth+2-1:0] mem_data_in_run;

	// SRAM address muxing

	logic WEB;
	logic [memory_addr_width-1:0] write_addr, addr;

	assign addr = (WEB == 1'b0) ? write_addr : in_addr;

	typedef enum logic [1:0] {WAIT_FOR_START, WAIT_FOR_EVENT, WRITE_ON_EVENT, MEM_FULL} ctrl_state_t;
	ctrl_state_t ctrl_state;

    always_comb begin
        mem_data_in_run = {data_event, counter};
        mem_data_init[counter_bitwidth+1:counter_bitwidth] = 2'b01;
        mem_data_init[counter_bitwidth-1:bitwidth] = 0;
        mem_data_init[bitwidth-1:0] = in;
    end

	always @(posedge clk) begin
		if (rstb == 1'b0) begin
			WEB <= 1'b1;
			write_addr <= 'd0;
			ctrl_state <= WAIT_FOR_START;
		end else begin
			case (ctrl_state)
				WAIT_FOR_START : begin
					WEB <= (trigger == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= 'd0;
					ctrl_state <= (trigger == 1'b1) ? WAIT_FOR_EVENT : WAIT_FOR_START;
                    mem_data_in <= mem_data_init;
				end
                WAIT_FOR_EVENT : begin
                    WEB <= (mem_write_trigger == 1'b1) ? 1'b0 : 1'b1;
                    write_addr <= (mem_write_trigger == 1'b1) ? write_addr + 1 : write_addr;
                    ctrl_state <= (mem_write_trigger == 1'b1) ? WRITE_ON_EVENT : WAIT_FOR_EVENT;
                    mem_data_in <= mem_data_in_run;
                end
				WRITE_ON_EVENT : begin
					WEB <= (mem_write_trigger == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= (mem_write_trigger == 1'b1) ? write_addr + 1 : write_addr;
					ctrl_state <= (write_addr == max_addr) ? MEM_FULL : (mem_write_trigger == 1'b1) ? WRITE_ON_EVENT : WAIT_FOR_EVENT;
                    mem_data_in <= mem_data_in_run;
				end
				MEM_FULL : begin
					WEB <= 1'b1;
					write_addr <= max_addr;
					ctrl_state <= (trigger == 1'b0) ? WAIT_FOR_START : MEM_FULL;
                    mem_data_in <= mem_data_in;
				end
				default : begin
					// same as WAIT_FOR_WRITE
					WEB <= (trigger == 1'b1) ? 1'b0 : 1'b1;
					write_addr <= 'd0;
					ctrl_state <= (trigger == 1'b1) ? WAIT_FOR_EVENT : WAIT_FOR_START;
                    mem_data_in <= mem_data_init;
				end	 
			endcase
		end
	end


    sram #(
        .ADR_BITS(memory_addr_width),
        .DAT_BITS(counter_bitwidth+2)
    ) sram_i (
        .CLK(clk),
        .CEB(1'b0),
        .WEB(WEB),
        .A(addr),
        .D(mem_data_in),
        .Q(mem_data_out)
    );  

endmodule : trig_tracker
