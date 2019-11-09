module mlsd_variable_top #(
    parameter integer numChannels   = 16,
    parameter integer codeBitwidth  = 8, 
    parameter integer estBitwidth   = 8, 
    parameter integer maxSeqLength  = 
) (
    input wire logic signed [codeBitwidth-1:0] codes [numChannels-1:0],
    input wire logic signed [estBitwidth-1:0] channel_est [numChannels-1:0][estDepth-1:0],

    input wire logic estimate_bits [numChannels-1:0],
    input wire logic flags [numChannels-1:0],

    input wire logic clk,
    input wire logic rstb, 

    output logic corrected_bits [numChannels-1:0]
);

endmodule : mlsd_variable_top
