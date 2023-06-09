module state_register_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer S_LEN = 2,
    parameter integer B_LEN = 2,
    parameter integer est_channel_width = 8,
    parameter integer est_channel_depth = 30,
    parameter integer est_channel_shift = 1
) (
    input logic clk,
    input logic rst_n,
    input logic signed [1:0] internal_tag_reg [S_LEN-1:0],

    input logic signed [est_channel_width-1:0] est_channel [est_channel_depth-1:0],
    input logic update,

    output logic signed [B_WIDTH-1:0] precomputed_state_val [B_LEN-1:0]

);

    logic signed [B_WIDTH-1:0] internal_precomputed_state_val [B_LEN-1:0];


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            precomputed_state_val <= '{default:0};
        end else begin
            if(update) begin
                for(int ii = 0; ii < S_LEN; ii++) begin
                    precomputed_state_val[ii] <= internal_precomputed_state_val[ii];
                end
            end
        end
    end

    conv_unit #(
        .i_width(2),
        .i_depth(S_LEN),
        .f_width(est_channel_width),
        .f_depth(est_channel_depth),
        .o_width(B_WIDTH),
        .o_depth(B_LEN),
        .offset(B_LEN),
        .shift(1)
    ) conv_i (
        .in(internal_tag_reg),
        // (B_LEN + S_LEN) represents the shifting implicit in this convolution when you consider the entire history
        // The (B_LEN-1) represents the effect of sliding the filter along multiple values (for unrolling the branches)
        .filter(est_channel),
        .out(internal_precomputed_state_val)
    );

endmodule 