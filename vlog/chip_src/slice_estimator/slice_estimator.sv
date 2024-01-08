`default_nettype none
module slice_estimator #(
    parameter integer num_of_channels = 16,
    parameter integer est_bit_bitwidth = 8,
    parameter integer adapt_bitwidth = 16
) (
    input wire logic clk,
    input wire logic rst_n,

    input wire logic signed [2:0] symbols [num_of_channels-1:0],
    input wire logic signed [est_bit_bitwidth-1:0] est_symbols [num_of_channels-1:0],

    input wire logic [$clog2(adapt_bitwidth)-1:0] gain,

    input wire logic force_slicers,
    input wire logic [est_bit_bitwidth-1:0] fe_bit_target_level,

    output logic signed [est_bit_bitwidth-1:0] slice_levels [2:0]
);

    always_comb begin
        slice_levels[0] = -2*fe_bit_target_level;
        slice_levels[1] = 0;
        slice_levels[2] = 2*fe_bit_target_level;
    end 






endmodule : slice_estimator
`default_nettype wire
