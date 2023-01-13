module energy_metric #(
    parameter integer est_err_bitwidth = 9,
    parameter integer ener_bitwidth = 18
) (
    input logic signed [est_err_bitwidth-1:0] injection_error_seq [seq_length-1:0], 
    input logic signed [est_err_bitwidth-1:0] est_error [seq_length-1:0],

    output logic [ener_bitwidth-1:0] energy
);

    always_comb begin
        energy = 0
        for(int ii =0; ii < seq_length; ii = ii + 1) begin
            energy += (injection_error_seq+est_error)**2;
        end
    end

endmodule 