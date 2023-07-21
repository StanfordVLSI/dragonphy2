module viterbi_input_controller #(
    parameter integer num_of_channels = 40,
    parameter integer error_width = 8,
    parameter integer branch_length = 2,
    parameter integer num_of_chunks = 5
) (
    input logic clk,
    input logic rst_n,


    input logic signed [error_width-1:0] residual_estimated_error [num_of_channels-1:0],
    input logic flags [num_of_channels-1:0],
    input logic [$clog2(num_of_chunks)-1:0] start_frame,
    input logic fifo_empty,

    output logic pop_n,
    output logic init_n,
    output logic clr,

    output logic signed [error_width-1:0] trace_vals [branch_length-1:0],
    output logic run,
    output logic initialize,
    output logic frame_end,

    output logic [$clog2(num_of_channels)- 1:0] idx
    
);

    typedef enum logic [2:0] {RESET, WAIT_FOR_EMPTY, INITIALIZE_VITERBI, RUN_VITERBI, GATHER_ADDITIONAL_FRAME, DONE} controller_state_t;

    controller_state_t ctrl_state, next_ctrl_state;

    logic [3:0] zero_value_count, next_zero_value_count;
    logic [$clog2(num_of_channels)+2- 1:0] next_idx;
    logic signed [error_width-1:0] current_frame [num_of_channels-1:0];
    logic current_flags [num_of_channels-1:0];
    logic signed [error_width-1:0] next_current_frame [num_of_channels-1:0];
    logic next_current_flags [num_of_channels-1:0];

    logic non_zero_flag;

    always_comb begin
        non_zero_flag = 0;
        for(int ii = 0; ii < branch_length; ii++) begin
            non_zero_flag = non_zero_flag || |current_flags[idx+ii];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_state <= RESET;
            for(int ii = 0; ii < num_of_channels; ii++) begin
                current_frame[ii] <= 0;
                current_flags[ii] <= 0;
            end
            idx <= 0;
            zero_value_count <= 0;
        end else begin
            ctrl_state <= next_ctrl_state;
            current_frame <= next_current_frame;
            idx <= next_idx;
            zero_value_count <= next_zero_value_count;
            current_flags <= next_current_flags;
        end
    end

    always_comb begin
        case(ctrl_state)
            RESET : begin
                next_ctrl_state <= WAIT_FOR_EMPTY;
                next_zero_value_count <= 0;
                next_idx <= 0;
                for(int ii = 0; ii < num_of_channels; ii++) begin
                    next_current_frame[ii] <= 0;
                end
            end
            WAIT_FOR_EMPTY : begin
                next_ctrl_state       <= fifo_empty ? WAIT_FOR_EMPTY : INITIALIZE_VITERBI;
                next_zero_value_count <= 0;
                next_idx              <= fifo_empty ? 0 : (start_frame << 3);
                for(int ii = 0; ii < num_of_channels; ii++) begin
                    next_current_frame[ii] <= fifo_empty ? 0 : residual_estimated_error[ii];
                    next_current_flags[ii] <= fifo_empty ? 0 : flags[ii];
                end
            end
            INITIALIZE_VITERBI : begin
                next_ctrl_state <= RUN_VITERBI;
                next_zero_value_count <= 0;
                next_idx <= idx + branch_length;
                next_current_frame <= current_frame;
            end
            RUN_VITERBI : begin
                if (zero_value_count >= 8) begin
                    next_ctrl_state <= DONE;
                end else begin
                    next_ctrl_state <= idx < num_of_channels - branch_length ? RUN_VITERBI : GATHER_ADDITIONAL_FRAME;
                end
                next_zero_value_count <= !non_zero_flag ? zero_value_count + 1 : 0;
                next_idx <= (idx < num_of_channels - branch_length ) ? idx + branch_length : 0 ;
                next_current_frame <= current_frame;
            end
            GATHER_ADDITIONAL_FRAME : begin
                next_ctrl_state <= fifo_empty ? GATHER_ADDITIONAL_FRAME : RUN_VITERBI;
                next_zero_value_count <= zero_value_count;
                next_idx <= 0;
                for(int ii = 0; ii < num_of_channels; ii++) begin
                    next_current_frame[ii] <= fifo_empty ? current_frame[ii] : residual_estimated_error[ii];
                end            
            end
            DONE : begin
                next_ctrl_state <= WAIT_FOR_EMPTY;
                next_zero_value_count <= zero_value_count;
                next_idx <= idx;
                next_current_frame <= current_frame;
            end
            default : begin
                next_ctrl_state <= RESET;
                next_zero_value_count <= 0;
                next_idx <= 0;
                for(int ii = 0; ii < num_of_channels; ii++) begin
                    next_current_frame[ii] <= 0;
                end
            end
        endcase
    end


    always_comb begin
        case(ctrl_state)
            RESET : begin
                for(int ii = 0; ii < branch_length; ii++) begin    
                    trace_vals[ii] <= 0;
                end                
                run <= 0;
                initialize <= 0;
                pop_n <= 1;
                init_n <= 1;
                clr <= 0;
                frame_end <= 1;
            end
            WAIT_FOR_EMPTY : begin
                for(int ii = 0; ii < branch_length; ii++) begin    
                    trace_vals[ii] <= 0;
                end               
                run <= 0;
                initialize <= 0;
                pop_n <= fifo_empty ? 1 : 0;
                init_n <= 1;
                clr <= 0;
                frame_end <= 1;
            end
            INITIALIZE_VITERBI : begin
                for(int ii = 0; ii < branch_length; ii++) begin    
                    trace_vals[ii] <= current_frame[idx+ii];
                end
                run <= 0;
                initialize <= 1;
                pop_n <= 1;
                init_n <= 1;
                clr <= 0;
                frame_end <= 1;
            end
            RUN_VITERBI : begin
                for(int ii = 0; ii < branch_length; ii++) begin
                    trace_vals[ii] <= current_frame[idx+ii];
                end
                run <= 1;
                initialize <= 0;
                pop_n <= 1;
                init_n <= 1;
                clr <= 0;
                frame_end <= 1;
            end
            GATHER_ADDITIONAL_FRAME : begin
                for(int ii = 0; ii < branch_length; ii++) begin    
                    trace_vals[ii] <= 0;
                end               
                run <= 0;
                initialize <= 0;
                pop_n <= fifo_empty ? 1 : 0;
                init_n <= 1;
                clr <= 0;
                frame_end <= fifo_empty ? 1 : 0;
            end
            DONE : begin
                for(int ii = 0; ii < branch_length; ii++) begin    
                    trace_vals[ii] <= 0;
                end               
                run <= 0;
                initialize <= 0;
                pop_n <=  1;
                init_n <= 1;
                clr <= 0;
                frame_end <= 0;
            end
            default : begin
            end
        endcase
    end


endmodule // viterbi_controller