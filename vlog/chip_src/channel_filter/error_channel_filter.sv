module error_channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic bitstream [(depth-1)+width-1:0],
    input logic flpstream [(depth-1)+width-1:0],

    input logic [delay_width+width_width-1:0] bitstream_delay,
    input logic [delay_width+width_width-1:0] flpstream_delay,
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift [width-1:0],


    output logic signed [est_code_bitwidth-1:0] error_out [width-1:0],
    output logic [delay_width+width_width-1:0] error_out_delay

);

    assign error_out_delay = bitstream_delay;

    localparam idx = depth - 1;

    logic signed [est_channel_bitwidth+$clog2(depth)-1:0] unshifted_error_out [width-1:0];

    integer ii, jj;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            unshifted_error_out[ii] = 0;
            for(jj=0; jj<depth; jj=jj+1) begin
                if (flpstream[ii+idx-jj]) begin
                    unshifted_error_out[ii] = unshifted_error_out[ii] + (bitstream[ii+idx-jj] ? -2*channel[ii][jj] : 2*channel[ii][jj]);
                end
            end
            error_out[ii] = unshifted_error_out[ii] >>> shift[ii];
        end
    end

endmodule : error_channel_filter