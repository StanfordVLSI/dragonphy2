module viterbi_output_controller #(
    parameter integer num_of_channels = 40,
    parameter integer error_width = 8,
    parameter integer branch_length = 2,
    parameter integer num_of_chunks = 5
) (
    input logic clk,
    input logic rst_n,

    input logic signed [2:0] corrections [branch_length-1:0],
    input logic run,
    input logic frame_end,
    input logic initialize,

    input logic [$clog2(num_of_channels)-1:0] frame_position,

    output logic signed [2:0] corrections_frame [num_of_channels-1:0],
    output logic push_n,
    output logic init_n,
    output logic clr

);

    assign push_n = !frame_end;
    assign init_n = !clr;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clr <= 1;
            for(int ii = 0; ii < num_of_channels; ii++) begin
                corrections_frame[ii] <= 0;
            end
        end else begin
            clr <= 0;
            if (run) begin 
                for(int ii =0; ii < branch_length; ii++ ) begin
                    corrections_frame[frame_position+ii] <= corrections[ii];
                    $display("corrections_frame[%0d] = %0d", frame_position+ii, corrections[ii]);
                end
            end
        end
    end


endmodule // viterbi_output_controller