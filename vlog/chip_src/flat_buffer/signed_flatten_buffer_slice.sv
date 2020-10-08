module signed_flatten_buffer_slice #(
    parameter integer numChannels = 16,
    parameter integer bitwidth    = 8,
    parameter integer buff_depth  = 5,
    parameter integer slice_depth = 3,
    parameter integer start       = 0
) (
    buffer,
    flat_slice
);



    input wire logic signed [bitwidth-1:0] buffer [numChannels-1:0][buff_depth-1:0];
    output     logic signed [bitwidth-1:0] flat_slice [numChannels*slice_depth-1:0];

    logic signed [bitwidth-1:0] buffer_slice [numChannels-1:0][slice_depth-1:0];


genvar gi, gj;
generate
    for(gi=0; gi < slice_depth; gi=gi+1) begin
        for(gj=0; gj<numChannels; gj=gj+1) begin
            assign buffer_slice[gj][gi] = buffer[gj][gi + start]; 
        end
    end
endgenerate

signed_flatten_buffer #(
    .numChannels(numChannels),
    .bitwidth   (bitwidth),
    .depth      (slice_depth)
) flat_buff_i (
    .buffer     (buffer_slice),
    .flat_buffer(flat_slice)
);

endmodule : signed_flatten_buffer_slice
