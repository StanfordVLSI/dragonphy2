module flat_mlsd_multi #(
    parameter integer numChannels   = 16,
    parameter integer codeBitwidth  = 8,
    parameter integer estBitwidth   = 8,
) (
    input wire logic signed [codeBitwidth-1:0] codes [numChannels-1:0],
    input wire logic signed [estBitwidth-1:0 channel_est [numChannels-1:0][estDepth-1:0], 
    input wire logic estimate_bits [numChannels-1:0]

    input wire logic clk, 
    input wire logic rstb,

    output logic corrected_bits [numChannels-1:0]
);

    wire logic mlsd_one_out [numChannels-1:0]
    wire logic flags [numChannels-1:0]

    genvar gi;
    generate
        for(gi=0; gi<numChannels; gi=gi+1) begin
            assign flags = mlsd_one_out ^ estimate_bits
        end
    endgenerate

    flat_mlsd #(
        .numChannels(numChannels), 
        .codeBitwidth(codeBitwidth), 
        .estBitwidth(estBitwidth), 
        .estDepth(estDepth), 
        .seqLength(1)
    ) mlsd_one (
        .codes(codes), 
        .channel_est(channel_est), 
        .estimate_bits(estimate_bits), 
        .clk(clk), 
        .rstb(rstb), 
        .predict_bits(mlsd_one_out)
    )

    mlsd_variable #(
    ) mlsd_nbit (
    )
    
endmodule : flat_mlsd_multi
