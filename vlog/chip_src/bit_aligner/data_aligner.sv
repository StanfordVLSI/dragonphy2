module data_aligner #(
    parameter integer width=16,
    parameter integer depth=2,
    parameter integer bitwidth=8,
    parameter integer delay_width=4,
    parameter integer width_width=4
) (
    input logic  [bitwidth-1:0] data_segment [width*depth-1:0],
    input logic [delay_width + width_width-1:0] data_segment_delay,


    input logic [$clog2(width*(depth-1))-1:0] align_pos,
    output logic [bitwidth-1:0] aligned_data [width-1:0],
    output logic [delay_width + width_width-1:0] aligned_data_delay

);
    initial assert(depth>1);

    assign aligned_data_delay = data_segment_delay + (width*(depth-1) - align_pos);


    integer ii;
    always_comb begin
        for(ii=0; ii<width; ii = ii + 1) begin
            aligned_data[ii] = data_segment[ii+align_pos];
        end
    end

endmodule : data_aligner
