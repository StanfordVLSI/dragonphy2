module channel_filter #(
    parameter integer width        = 16,
    parameter integer depth        = 30,
    parameter integer est_channel_bitwidth = 8,
    parameter integer est_code_bitwidth    = 8,
    parameter integer shift_bitwidth = 2,
    parameter integer delay_width=4,
    parameter integer width_width=4
) (
    input logic [1:0] bitstream [(depth-1)+width-1:0],
    input logic [delay_width+width_width-1:0] bitstream_delay,
    
    input logic signed [est_channel_bitwidth-1:0] channel [width-1:0][depth-1:0],
    input logic [shift_bitwidth-1:0] shift[width-1:0],

    output logic signed [est_code_bitwidth-1:0] est_code [width-1:0],
    output logic [delay_width+width_width-1:0] est_code_delay
);

    assign est_code_delay = bitstream_delay;

    localparam idx = depth - 1;

    logic signed [est_code_bitwidth+$clog2(depth)+2-1:0] int_est_code [width-1:0];


    integer ii, jj;
    always_comb begin
        for(ii=0; ii<width; ii=ii+1) begin
            int_est_code[ii] = 0;
            for(jj=0; jj<depth; jj=jj+1) begin
                unique case (bitstream[ii+idx-jj])
                    2'b10: int_est_code[ii] = int_est_code[ii] + 3*channel[ii][jj];
                    2'b11: int_est_code[ii] = int_est_code[ii] + 1*channel[ii][jj];
                    2'b01: int_est_code[ii] = int_est_code[ii] - 1*channel[ii][jj];
                    2'b00: int_est_code[ii] = int_est_code[ii] - 3*channel[ii][jj];
                endcase    
            end
            est_code[ii] = int_est_code[ii] >>> shift[ii];
        end
    end

endmodule : channel_filter