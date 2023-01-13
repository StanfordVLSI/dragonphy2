module argmin #(
    parameter integer num_of_energies = 3,
    parameter integer ener_bitwidth = 18
) (
    input logic [ener_bitwidth-1:0] energies [num_of_energies-1:0],

    output logic [$clog2(num_of_energies)-1:0] lowest_energy_idx,
    output logic [ener_bitwidth-1:0] lowest_energy
);


    always_comb begin
        lowest_energy_idx = 0;
        lowest_energy = energies[0];
        for(int ii = 1; ii < num_of_energies; ii += 1) begin
            if (energies[ii] < lowest_energy) begin
                lowest_energy_idx = ii;
                lowest_energy = energies[ii];
            end
        end
    end
endmodule 