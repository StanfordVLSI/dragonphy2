module stitch_error_injector #(
    parameter integer width=16,
    parameter integer seq_length=3,
    parameter integer cursor_loc=1,

) (

    // Need to add an offset for cursor location
    input logic bitstream [width*3 -1:0],
    input logic signed [est_bitwidth-1:0] est_error [width*3-1:0],

    input logic signed [est_bitwidth-1:0] precomp_errors [3:0][seq_length-1:0]

    output logic signed [est_bitwidth-1:0] est_injected_error [width-1:0][seq_length-1:0]
);

    // Need to add an offset for cursor location
    // Probably should be done by skewing the actual codes earlier on so this doesn't need to be done at all..

    logic [width*3-1:0] packed_bitstream;

    assign packed_bitstream = {>>{bitstream}};

    integer ii,jj, ss;
    always_comb begin
        for(ii=0;ii<width; ii=ii+1) begin
            ss = ii+width;
            for(jj=0; jj<seq_length; jj=jj+1) begin
                est_injected_error[ii][jj] = est_error[ss+jj-cursor_loc]
                                           + precomp_errors[!packed_bitstream[ss:ss+1]][jj];
            end
        end
    end


endmodule : stitch_error_injector