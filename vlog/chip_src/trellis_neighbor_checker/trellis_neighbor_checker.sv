module trellis_neighbor_checker #(
    parameter integer est_channel_bitwidth = 10,
    parameter integer depth = 30,
    parameter integer width = 16,
    parameter integer branch_bitwidth  = 2,
    parameter integer shift_bitwidth = 3,
    parameter integer trellis_neighbor_checker_depth = 2,
    parameter integer num_of_trellis_patterns = 4,
    parameter integer trellis_pattern_depth = 4,
    parameter integer seq_length = 3,
    parameter integer ener_bitwidth = 18,
    parameter integer est_err_bitwidth=9
) (
    input logic signed [est_channel_bitwidth-1:0]          channel          [depth-1:0],
    input logic signed [shift_bitwidth-1:0]                channel_shift,
    input logic signed [branch_bitwidth-1:0]               trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
    input logic nrz_mode,
    input logic signed [est_err_bitwidth-1:0]              errstream [width*trellis_neighbor_checker_depth-1:0],

    output logic [$clog2(2*num_of_trellis_patterns+1)-1:0] flags [width-1:0],
    output logic [ener_bitwidth-1:0] flag_eners [width-1:0]

);
    logic signed [est_channel_bitwidth-1:0]  channel_slice [seq_length+trellis_pattern_depth-1-1:0];
    logic signed [est_err_bitwidth-1:0] errstream_slice [width-1:0][seq_length-1:0];
    logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0];
    logic [ener_bitwidth-1:0] null_energies [width-1:0];
    logic [ener_bitwidth-1:0] null_diff_sq  [width-1:0][seq_length-1:0];
    logic [ener_bitwidth-1:0] best_energies [width-1:0];

    assign channel_slice = channel[seq_length+trellis_pattern_depth-1-1:0];
    assign flag_eners = best_energies;
    error_injection_engine #(
        .seq_length(seq_length),
        .est_err_bitwidth(est_err_bitwidth),
        .trellis_pattern_depth(trellis_pattern_depth),
        .branch_bitwidth(branch_bitwidth),
        .shift_bitwidth(shift_bitwidth),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .cp(2),
        .est_channel_bitwidth(est_channel_bitwidth)
    ) eie_i (
        .channel(channel_slice),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(nrz_mode),
        .injection_error_seqs(injection_error_seqs)
    );

    genvar gi, gj;
    generate

        for(gi = 0; gi < width; gi += 1) begin
            for(gj = 0; gj < seq_length; gj += 1) begin
                assign errstream_slice[gi][gj] = errstream[width-seq_length + gi+gj];
            end

            always_comb begin
                null_energies[gi] = 0;
                for(int ii =0; ii < seq_length; ii += 1) begin
                    null_diff_sq[gi][ii] = errstream_slice[gi][ii]**2;
                    null_energies[gi] += null_diff_sq[gi][ii];
                end
                null_energies[gi] = null_energies[gi];
            end

            trellis_neighbor_checker_slice #(
                .num_of_trellis_patterns(num_of_trellis_patterns),
                .seq_length(seq_length),
                .est_err_bitwidth(est_err_bitwidth),
                .ener_bitwidth(ener_bitwidth)
            ) tnc_slice_i (
                .injection_error_seqs(injection_error_seqs),
                .est_error(errstream_slice[gi]),
                .null_energy(null_energies[gi]),
                .best_ener_idx(flags[gi]),
                .best_energy(best_energies[gi])
            );
        end
    endgenerate

    function automatic string format_channel_array(input  logic signed [est_channel_bitwidth-1:0] channel [seq_length+trellis_pattern_depth-1-1:0]);
        string str;
        str = {"{", $sformatf("%d", channel[seq_length + trellis_pattern_depth -1 -1])};
        for(int ii = seq_length + trellis_pattern_depth -1 -2 ; ii >= 0; ii = ii - 1) begin
            str = {str, $sformatf(", %d", channel[ii])};
        end
        str = {str, "}"};

        return str;
    endfunction

    function automatic string format_errstream_array(input  logic signed [est_err_bitwidth-1:0] errstream [seq_length-1:0]);
        string str;
        str = {"{", $sformatf("%d", errstream[seq_length-1])};
        for(int ii = seq_length -2 ; ii >= 0; ii = ii - 1) begin
            str = {str, $sformatf(", %d", errstream[ii])};
        end
        str = {str, "}"};

        return str;
    endfunction

    function automatic string format_ies_array(input  logic signed [est_err_bitwidth-1:0] injection_error_seq [seq_length-1:0]);
        string str;
        str = {"{", $sformatf("%d", injection_error_seq[seq_length-1])};
        for(int ii = seq_length -2 ; ii >= 0; ii = ii - 1) begin
            str = {str, $sformatf(", %d", injection_error_seq[ii])};
        end
        str = {str, "}"};

        return str;
    endfunction


endmodule 