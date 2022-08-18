`define MAX(arg1, arg2) ((arg1 > arg2) ? arg1 : arg2)

module sliding_detector_v2 #(
    parameter integer seq_length=3,
    parameter integer width=16,
    parameter integer depth=30,
    parameter integer num_of_flip_patterns = 4,
    parameter integer flip_pattern_depth   = 3,
    parameter integer flip_patterns[num_of_flip_patterns-1:0][flip_pattern_depth-1:0] = '{'{0,1,0}, '{0,1,1}, '{1,1,1},'{1,0,1}},
    parameter integer est_error_bitwidth=8,
    parameter integer est_channel_bitwidth=8,
    parameter integer sliding_detector_depth=2,
    parameter integer cp=2,
    parameter integer max_bitwidth = `MAX(est_channel_bitwidth, est_channel_bitwidth+1),
    parameter integer ener_bitwidth = 18,
    parameter integer delay_width = 4,
    parameter integer width_width = 4
) (
    input logic signed [est_error_bitwidth-1:0]   errstream [width*sliding_detector_depth-1:0],
    input logic                                   bitstream [width*sliding_detector_depth-1:0],
    input logic [delay_width+width_width-1:0] errstream_delay,
    input logic [delay_width+width_width-1:0] bitstream_delay,
    input logic signed [est_channel_bitwidth-1:0] channel   [width-1:0][depth-1:0],

    output logic [ener_bitwidth-1:0]                  mmse_vals [width-1:0],
    output logic [$clog2(num_of_flip_patterns+1)-1:0] err_flags [width-1:0],
    output logic [delay_width+width_width-1:0] mmse_vals_delay,
    output logic [delay_width+width_width-1:0] err_flags_delay
);

logic signed [est_error_bitwidth-1:0]     errstream_slice [width-1:0][seq_length-1:0];
logic                                     bitstream_slice [width-1:0][seq_length-1:0];
logic  signed [est_channel_bitwidth-1:0]  channel_slice   [width-1:0][seq_length+flip_pattern_depth-1-1:0];


// synthesis translate_off
assign mmse_vals_delay = errstream_delay + seq_length + cp;
assign err_flags_delay = errstream_delay + seq_length + cp;
// synthesis translate_on
genvar gi, gj;

generate
    for(gi = 0; gi < width; gi += 1) begin
        for(gj = 0; gj < seq_length; gj += 1) begin
            assign errstream_slice[gi][gj] = errstream[width-seq_length+gi+gj];
            assign bitstream_slice[gi][gj] = bitstream[width-seq_length-cp+gi+gj];
        end

        for(gj = 0; gj < flip_pattern_depth + seq_length-1; gj += 1) begin
            assign channel_slice[gi][gj] = channel[gi][gj];
        end

        sliding_detector_single_slice #(
            .seq_length(seq_length), 
            .est_error_bitwidth(est_error_bitwidth), 
            .est_channel_bitwidth(est_channel_bitwidth),
            .num_of_flip_patterns(num_of_flip_patterns),
            .flip_pattern_depth  (flip_pattern_depth),
            .flip_patterns(flip_patterns),
            .max_bitwidth(max_bitwidth),
            .ener_bitwidth(ener_bitwidth)
        ) sd_slice_i (
            .residual_error_trace(errstream_slice[gi]),
            .bits(bitstream_slice[gi]),
            .channel(channel_slice[gi]),
            .error_flag(err_flags[gi]),
            .mmse_val(mmse_vals[gi])
        );
    end
endgenerate

endmodule : sliding_detector_v2
