module coarse_flag_blocker #(
    parameter integer num_of_chunks = 5,
    parameter integer flag_width = 8,
    parameter integer num_of_channels = 40
) (
    input logic signed [flag_width-1:0] flags [num_of_channels-1:0],
    output logic [num_of_chunks-1:0] coarse_flags
);

    logic [num_of_channels-1:0] bit_flags;

    always_comb begin : blocker
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            bit_flags[ii] = (flags[ii] == 0) ? 0 : 1;
        end
    end

    genvar gi;

    generate
        for(gi = 0; gi < num_of_chunks; gi += 1) begin
            assign coarse_flags[gi] = |bit_flags[(gi+1)*num_of_channels/num_of_chunks-1:gi*num_of_channels/num_of_chunks];
        end
    endgenerate


endmodule // coarse_flag_blocker