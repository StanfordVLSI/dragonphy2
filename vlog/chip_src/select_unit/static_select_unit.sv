module static_select_unit #(
    parameter integer N_S = 4,
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8,
    parameter integer S_LEN = 2
) (
    input logic [2*B_WIDTH-1:0] state_energies [N_S-1:0],
    input logic signed [1:0] state_histories [N_S-1:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] best_state_energy,
    output logic signed [1:0] best_state_history [H_DEPTH-1:0]
);

    genvar gi, gj;
    generate
        if (N_S > 4) begin: se
            logic [2*B_WIDTH-1:0] input_state_energies [7:0];
            logic signed [1:0] input_state_histories [7:0][H_DEPTH-1:0];
            for(gi = 0; gi < N_S; gi = gi + 1) begin: ip
                assign input_state_energies[gi] = state_energies[gi];
                assign input_state_histories[gi] = state_histories[gi];
            end
            for( gi = N_S; gi < 8; gi = gi + 1) begin : zr
                assign input_state_energies[gi] =  2**(2*B_WIDTH)-1;
                for(gj = 0; gj < H_DEPTH; gj = gj + 1) begin
                    assign input_state_histories[gi][gj] = 0;
                end
            end
            select_eight #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) se_i (
                .energies(input_state_energies),
                .histories(input_state_histories),
                .selected_energy(best_state_energy),
                .selected_history(best_state_history)
            );

        end else if (N_S > 2) begin: sf
            logic [2*B_WIDTH-1:0] input_state_energies [3:0];
            logic signed [1:0] input_state_histories [3:0][H_DEPTH-1:0];
            for(gi = 0; gi < N_S; gi = gi + 1) begin: ip
                assign input_state_energies[gi] = state_energies[gi];
                assign input_state_histories[gi] = state_histories[gi];
            end
            for( gi = N_S; gi < 4; gi = gi + 1) begin : zr
                assign input_state_energies[gi] = 2**B_WIDTH-1;
                for(gj = 0; gj < H_DEPTH; gj = gj + 1) begin
                    assign input_state_histories[gi][gj] = 0;
                end
            end
            select_four #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) se_i (
                .energies(input_state_energies),
                .histories(input_state_histories),
                .selected_energy(best_state_energy),
                .selected_history(best_state_history)
            );
        end else if (N_S == 2) begin : st
            select_two #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) se_i (
                .energies(state_energies),
                .histories(state_histories),
                .selected_energy(best_state_energy),
                .selected_history(best_state_history)
            );
        end else begin
            assign best_state_energy = state_energies[0];
            assign best_state_history = state_histories[0];
        end
    endgenerate
endmodule