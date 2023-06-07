module select_two #(
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8
) (
    input logic [2*B_WIDTH-1:0] energies [1:0],
    input logic signed [1:0]    histories [1:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] selected_energy,
    output logic signed [1:0] selected_history [H_DEPTH-1:0]
);

	always_comb begin
        if (energies[0] < energies[1]) begin
            selected_energy = energies[0];
            for(int ii = 0; ii < H_DEPTH; ii += 1) begin
                selected_history[ii] = histories[0][ii];
            end
        end else begin
            selected_energy = energies[1];
            for(int ii = 0; ii < H_DEPTH; ii += 1) begin
                selected_history[ii] = histories[1][ii];
            end
        end
	end


endmodule