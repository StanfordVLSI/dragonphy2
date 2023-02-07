module test;
    localparam integer bitwidth=8;
    localparam integer seq_length = 3;
    localparam integer est_err_bitwidth = 9;
    localparam integer trellis_pattern_depth = 4;
    localparam integer branch_bitwidth = 2;
    localparam integer num_of_trellis_patterns = 4;
    localparam integer cp = 2;
    localparam integer est_channel_bitwidth = 10;

    logic signed [est_channel_bitwidth-1:0] channel [(seq_length+trellis_pattern_depth-1)-1:0];
    logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0];
    logic nrz_mode;
    logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0];
    logic [2:0] channel_shift;

    error_injection_engine #(
        .seq_length(seq_length),
        .est_err_bitwidth(est_err_bitwidth),
        .trellis_pattern_depth(trellis_pattern_depth),
        .branch_bitwidth(branch_bitwidth),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .cp(2),
        .shift_width(3),
        .est_channel_bitwidth(est_channel_bitwidth)
    ) eie_i (
        .channel(channel),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(nrz_mode),
        .channel_shift(channel_shift),
        .injection_error_seqs(injection_error_seqs)
    ) ;

    initial begin
        read_inputs_from_file("eie_inputs.txt", channel_shift, nrz_mode, channel, trellis_patterns);
        #(1ns);
        write_outputs_to_file("eie_outputs.txt", injection_error_seqs);
        $finish;
    end

task read_inputs_from_file(input string filename, output logic [2:0] channel_shift, output logic nrz_mode, output logic signed [est_channel_bitwidth-1:0] channel [(seq_length+trellis_pattern_depth-1)-1:0], output logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0]);
    integer file_id;
    file_id =  $fopen(filename, "r");

    $fscanf(file_id, "%d", channel_shift);
    $fscanf(file_id, "%d", nrz_mode);

    for(int ii = 0; ii < seq_length+trellis_pattern_depth-1; ii = ii + 1) begin
        $fscanf(file_id, "%d", channel[ii]);
    end

    for(int ii = 0; ii < num_of_trellis_patterns; ii = ii + 1) begin
        for(int jj = 0; jj < trellis_pattern_depth; jj = jj + 1) begin
            $fscanf(file_id, "%d", trellis_patterns[ii][jj]);
        end
    end

    $fclose(file_id);
endtask

task write_outputs_to_file(input string filename, input logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0]);
    integer file_id;
    file_id = $fopen(filename, "w");

    for(int ii = 0; ii < 2*num_of_trellis_patterns; ii = ii + 1) begin
        $fwrite(file_id, "%s\n", format_array(injection_error_seqs[ii]));
    end

    $fclose(file_id);
endtask

function automatic string format_array(input  logic signed [est_err_bitwidth-1:0] injection_error_seq [seq_length-1:0]);
    string str;
    str = {"{", $sformatf("%d", injection_error_seq[seq_length-1])};
    for(int ii = seq_length -2 ; ii >= 0; ii = ii - 1) begin
        str = {str, $sformatf(", %d", injection_error_seq[ii])};
    end
    str = {str, "}"};

    return str;
endfunction


endmodule : test
