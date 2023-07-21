module start_frame_decoder #(
    parameter integer num_of_chunks = 5
) (
    input logic clk,
    input logic rst_n,

    input logic [num_of_chunks-1:0] coarse_flags,
    
    output logic is_there_edge,
    output logic loc_1,
    output logic loc_2,
    output logic [1:0] num_of_writes
);

    logic [2+num_of_chunks-1:0] decoder_input;
    logic [num_of_chunks-1:0] previous_coarse_flags;
    logic [4:0] first_stage_decode;

    assign decoder_input = {coarse_flags, previous_coarse_flags};

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            previous_coarse_flags[0] <= 0;
            previous_coarse_flags[1] <= 0;
        end
        else begin
            previous_coarse_flags <= coarse_flags[num_of_chunks-1:num_of_chunks-2];
        end
    end

    always_comb begin : decoder
        for (int ii = 0; ii < num_of_chunks; ii++) begin
            first_stage_decode[ii] = decoder_input[ii+2] | !decoder_input[ii+1] | !decoder_input[ii];
        end

        is_there_edge = first_stage_decode[num_of_chunks-1];        

        num_of_writes = 0;
        for (int ii = 0; ii < num_of_chunks; ii++) begin
            num_of_writes = num_of_writes + first_stage_decode[ii];
        end

        case (first_stage_decode)
            5'b00001: begin
                loc_1 = 0;
                loc_2 = 0;
            end
            5'b10001: begin
                loc_1 = 0;
                loc_2 = 4;
            end
            5'b01001: begin
                loc_1 = 0;
                loc_2 = 3;
            end
            5'b00010: begin
                loc_1 = 1;
                loc_2 = 0;
            end
            5'b10010: begin
                loc_1 = 1;
                loc_2 = 4;
            end
            5'b00100: begin
                loc_1 = 2;
                loc_2 = 0;
            end
            5'b01000: begin
                loc_1 = 3;
                loc_2 = 0;
            end
            5'b10000: begin
                loc_1 = 4;
                loc_2 = 0;
            end
            default: begin
                loc_1 = 0;
                loc_2 = 0;
            end
        endcase
    end


endmodule // start_frame_decoder