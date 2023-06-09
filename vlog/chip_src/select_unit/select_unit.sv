module select_unit #(
    parameter integer N_B = 8,
    parameter integer H_DEPTH = 4,
    parameter integer B_WIDTH = 8,
    parameter integer S_LEN = 2
) (
    input logic [2*B_WIDTH-1:0] path_energies [N_B-1:0],
    input logic signed [1:0] path_histories [N_B-1:0][H_DEPTH-1:0],

    output logic [2*B_WIDTH-1:0] selected_path_energy,
    output logic signed [1:0] selected_path_history [H_DEPTH-1:0]
);
    genvar gi, gj;
    generate
        if (N_B > 16) begin: ss
            logic [2*B_WIDTH-1:0] input_path_energies [31:0];
            logic signed [1:0] input_path_histories [31:0][H_DEPTH-1:0];
            for(gi = 0; gi < N_B; gi = gi + 1) begin: ip
                assign input_path_energies[gi] = path_energies[gi];
                assign input_path_histories[gi] = path_histories[gi];
            end
            for( gi = N_B; gi < 32; gi = gi + 1) begin : zr
                assign input_path_energies[gi] = 2**(2*B_WIDTH)-1;
                for(gj = 0; gj < H_DEPTH; gj = gj + 1) begin
                    assign input_path_histories[gi][gj] = 0;
                end
            end
            select_thirtytwo #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) ss_i (
                .energies(input_path_energies),
                .histories(input_path_histories),
                .selected_energy(selected_path_energy),
                .selected_history(selected_path_history)
            );
        end else if (N_B > 8) begin: ss
            logic [2*B_WIDTH-1:0] input_path_energies [15:0];
            logic signed [1:0] input_path_histories [15:0][H_DEPTH-1:0];
            for(gi = 0; gi < N_B; gi = gi + 1) begin: ip
                assign input_path_energies[gi] = path_energies[gi];
                assign input_path_histories[gi] = path_histories[gi];
            end
            for( gi = N_B; gi < 16; gi = gi + 1) begin : zr
                assign input_path_energies[gi] = 2**(2*B_WIDTH)-1;
                for(gj = 0; gj < H_DEPTH; gj = gj + 1) begin
                    assign input_path_histories[gi][gj] = 0;
                end
            end
            select_sixteen #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) ss_i (
                .energies(input_path_energies),
                .histories(input_path_histories),
                .selected_energy(selected_path_energy),
                .selected_history(selected_path_history)
            );
        end else if (N_B > 4) begin: se
            logic [2*B_WIDTH-1:0] input_path_energies [7:0];
            logic signed [1:0] input_path_histories [7:0][H_DEPTH-1:0];
            for(gi = 0; gi < N_B; gi = gi + 1) begin: ip
                assign input_path_energies[gi] = path_energies[gi];
                assign input_path_histories[gi] = path_histories[gi];
            end
            for( gi = N_B; gi < 8; gi = gi + 1) begin : zr
                assign input_path_energies[gi] = 2**(2*B_WIDTH)-1;
                for(gj = 0; gj < H_DEPTH; gj = gj + 1) begin
                    assign input_path_histories[gi][gj] = 0;
                end
            end
            select_eight #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) se_i (
                .energies(input_path_energies),
                .histories(input_path_histories),
                .selected_energy(selected_path_energy),
                .selected_history(selected_path_history)
            );
        end else if (N_B > 2) begin: sf
            logic [2*B_WIDTH-1:0] input_path_energies [3:0];
            logic signed [1:0] input_path_histories [3:0][H_DEPTH-1:0];
            for(gi = 0; gi < N_B; gi = gi + 1) begin: ip
                assign input_path_energies[gi] = path_energies[gi];
                assign input_path_histories[gi] = path_histories[gi];
            end
            for( gi = N_B; gi < 4; gi = gi + 1) begin : zr
                assign input_path_energies[gi] = 2**(2*B_WIDTH)-1;
                for(gj = 0; gj < H_DEPTH; gj = gj + 1) begin
                    assign input_path_histories[gi][gj] = 0;
                end
            end
            select_four #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) se_i (
                .energies(input_path_energies),
                .histories(input_path_histories),
                .selected_energy(selected_path_energy),
                .selected_history(selected_path_history)
            );
        end else if (N_B == 2) begin : st
            select_two #(
                .H_DEPTH(H_DEPTH),
                .B_WIDTH(B_WIDTH)
            ) se_i (
                .energies(path_energies),
                .histories(path_histories),
                .selected_energy(selected_path_energy),
                .selected_history(selected_path_history)
            );
        end else begin
            assign selected_path_energy = path_energies[0];
            assign selected_path_history = path_histories[0];
        end
    endgenerate
endmodule