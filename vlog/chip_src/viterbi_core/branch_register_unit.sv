module branch_register_unit #(
    parameter integer B_WIDTH = 9,
    parameter integer B_LEN = 3,
    parameter integer est_channel_width = 8,
    parameter integer est_channel_depth = 18,
    parameter integer est_channel_shift = 1
) (
    input logic clk,
    input logic rst_n,

    input logic signed [est_channel_width-1:0] est_channel [est_channel_depth-1:0],
    input logic update,
    input logic signed [1:0] internal_tag_reg [B_LEN-1:0],


    output logic signed [B_WIDTH-1:0] precomputed_branch_val [B_LEN-1:0]

);

    logic signed [B_WIDTH-1:0] internal_precomputed_branch_val [B_LEN-1:0];

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            precomputed_branch_val <= '{default:0};
        end else begin
            if(update) begin
                precomputed_branch_val <= internal_precomputed_branch_val;
            end
        end
    end

    conv_unit #(
        .i_width(2),
        .i_depth(B_LEN),
        .f_width(est_channel_width),
        .f_depth(est_channel_depth),
        .o_width(B_WIDTH),
        .o_depth(B_LEN),
        .offset(0),
        .shift(1)
    ) conv_i (
        .in(internal_tag_reg),
        // (B_LEN + S_LEN) represents the shifting implicit in this convolution when you consider the entire history
        // The (B_LEN-1) represents the effect of sliding the filter along multiple values (for unrolling the branches)
        .filter(est_channel),
        .out(internal_precomputed_branch_val)
    );

endmodule 