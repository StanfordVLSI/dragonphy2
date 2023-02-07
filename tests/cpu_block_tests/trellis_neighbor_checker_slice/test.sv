module test;

    localparam integer seq_length = 3;
    localparam integer est_err_bitwidth = 9;
    localparam integer num_of_trellis_patterns = 4;
    localparam integer ener_bitwidth = 20;

    logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0];
    logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0];
    logic signed [ener_bitwidth-1:0] null_energy;

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] best_ener_idx;

    trellis_neighbor_checker_slice #(
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .seq_length(seq_length),
        .est_err_bitwidth(est_err_bitwidth),
        .ener_bitwidth(ener_bitwidth)
    ) tnc_slice_i (
        .injection_error_seqs(injection_error_seqs),
        .est_error(est_error),
        .null_energy(null_energy),
        .best_ener_idx(best_ener_idx)
    );

    initial begin
        read_tnc_inputs_from_file("tnc_inputs.txt", injection_error_seqs, est_error, null_energy);
        #(1ns);
        write_tnc_outputs_to_file("tnc_outputs.txt", best_ener_idx);
        $finish;
    end

    task read_tnc_inputs_from_file(
        input string filename, 
        output logic signed [est_err_bitwidth-1:0] injection_error_seqs [2*num_of_trellis_patterns-1:0][seq_length-1:0],
        output logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0],
        output logic signed [ener_bitwidth-1:0] null_energy
    );
        integer file_id;
        file_id =  $fopen(filename, "r");

        for(int ii = 0; ii < 2*num_of_trellis_patterns; ii = ii + 1) begin
            for(int jj = 0; jj < seq_length; jj = jj + 1) begin
                $fscanf(file_id, "%d", injection_error_seqs[ii][jj]);
            end
        end

        for(int ii = 0; ii < seq_length; ii = ii + 1) begin
            $fscanf(file_id, "%d", est_error[ii]);
        end

        $fscanf(file_id, "%d", null_energy);

        $fclose(file_id);
    endtask

    task write_tnc_outputs_to_file(input string filename, input logic [$clog2(2*num_of_trellis_patterns+1)-1:0] best_ener_idx);
        integer file_id;
        file_id = $fopen(filename, "w");

        $fwrite(file_id, "%d", best_ener_idx);
        $fclose(file_id);
    endtask

endmodule : test
