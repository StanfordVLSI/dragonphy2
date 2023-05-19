module global_static_unit #(

) (
    input logic clk,
    input logic rst_n,

    input logic [2*B_WIDTH-1:0] state_energies [N_S-1:0],
    input logic [1:0] state_histories [N_S-1:0][N_H-1:0],
    input logic signed [est_channel_width-1:0] est_channel [est_chan_depth-1:0],

    input logic signed [B_WIDTH-1:0] rse_vals [B_LEN-1:0],

    output logic signed [B_WIDTH-1:0] precomputed_static_val [B_LEN-1:0],
    output logic [2*B_WIDTH-1:0] global_static_energy
);
    logic [1:0] global_static_history [N_H-1:0];

    conv #() conv_i (
        .in(global_static_history),
        .filter(est_channel),
        .out(static_val)
    );

    assign precomputed_static_val = static_val + rse_vals;

    static_select_unit #() ssu_i (
        .state_energies(state_energies),
        .state_histories(state_histories),

        .best_state_energy(best_state_energy),
        .best_state_history(best_state_history)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            global_static_history <= 0;
            global_static_energy  <= 0;
        end else begin
            global_static_history <= best_state_history;
            global_static_energy  <= best_state_energy;
        end
    end


endmodule 