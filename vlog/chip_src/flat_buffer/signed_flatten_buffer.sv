module signed_flatten_buffer #(
    parameter integer numChannels = 16,
    parameter integer bitwidth    = 8,
    parameter integer depth       = 5
) (
    buffer,
    flat_buffer
);


        input wire logic signed [bitwidth-1:0] buffer [numChannels-1:0][depth:0];
        output logic signed [bitwidth-1:0] flat_buffer [numChannels*(1+depth)-1:0];


genvar gi, gj;
generate 
    for(gj=0; gj<numChannels; gj=gj+1) begin
        for(gi=0; gi<depth+1; gi=gi+1) begin
            assign flat_buffer[(depth - gi)*numChannels + gj] = buffer[gj][gi];
        end
    end
endgenerate

endmodule : signed_flatten_buffer