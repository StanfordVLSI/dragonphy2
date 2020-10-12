module signed_flat_buffer #(
    parameter integer numChannels = 16,
    parameter integer bitwidth    = 8,
    parameter integer depth       = 5
) (
    input  logic signed [bitwidth-1:0] in [numChannels-1:0],
    input  logic clk,
    input  logic rstb,
    output     logic signed [bitwidth-1:0] flat_out [numChannels*(1+depth)-1:0]
);


    logic signed [bitwidth-1:0] internal_pipeline [numChannels-1:0][depth:0];




signed_buffer #(
    .numChannels(numChannels),
    .bitwidth   (bitwidth),
    .depth      (depth),
    .is_signed  (is_signed)
) buff_i (
    .in    (in),
    .clk   (clk),
    .rstb  (rstb),
    .buffer(internal_pipeline)
);

signed_flatten_buffer #(
    .numChannels(numChannels),
    .bitwidth   (bitwidth),
    .depth      (depth),
    .is_signed(is_signed)
) fbuff_i (
    .buffer     (internal_pipeline),
    .flat_buffer(flat_out)
);

endmodule : signed_flat_buffer
