module energy_metric #(
    parameter integer est_err_bitwidth = 9,
    parameter integer seq_length = 4,
    parameter integer ener_bitwidth = 18
) (
    input logic signed [est_err_bitwidth-1:0] injection_error_seq [seq_length-1:0], 
    input logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0],

    output logic [ener_bitwidth-1:0] energy
);

    logic signed [est_err_bitwidth:0] error_diff [seq_length-1:0];
    logic        [ener_bitwidth-1:0] error_diff_sq [seq_length-1:0];

    always_comb begin
        for(int ii =0; ii < seq_length; ii = ii + 1) begin
            error_diff[ii] =  est_error[ii] - injection_error_seq[ii];
            error_diff_sq[ii] = error_diff[ii]**2;
        end

        energy = 0;
        for(int ii =0; ii < seq_length; ii = ii + 1) begin
            energy += error_diff_sq[ii];
            //$display("energy at iteration %d = %d", ii, energy);
        end
        energy = energy;
    end

endmodule 