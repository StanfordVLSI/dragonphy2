module trigger #(
    parameter logic polarity = 1'b1
)(
    input logic clk,
    input logic rstb,

	input logic global_trigger,
    input logic local_trigger,
	
    output logic aligned_trigger
);
    logic local_trigger_prev, local_trigger_edge;

    always_ff @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin
            local_trigger_prev <= 0;
        end else begin
            local_trigger_prev <= local_trigger;
        end
    end


    generate
        if (polarity == 1'b1) begin
            assign local_trigger_edge = local_trigger & ~local_trigger_prev;
        end else begin
            assign local_trigger_edge = ~local_trigger & local_trigger_prev;
        end
    endgenerate

	typedef enum logic [1:0] {RESET, GLOBAL, LOCAL} state_t;
	state_t state, next_state;

    always_ff @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin
            state <= RESET;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            RESET: begin
                next_state = (global_trigger == 1'b1) ? GLOBAL : RESET;
            end
            GLOBAL: begin
                next_state = (local_trigger_edge == 1'b1) ? LOCAL : GLOBAL;
            end
            LOCAL: begin
                next_state = (global_trigger == 1'b0) ? RESET : LOCAL;
            end
            default: begin
                next_state = RESET;
            end
        endcase
    end
	
    always_comb begin
        case(state)
            RESET: begin
                aligned_trigger = 0;
            end
            GLOBAL: begin
                aligned_trigger = 0;
            end
            LOCAL: begin
                aligned_trigger = 1;
            end
            default: begin
                aligned_trigger = 0;
            end
        endcase
    end

endmodule : trigger
