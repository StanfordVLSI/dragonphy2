module branch_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer P_WIDTH = 8,
    parameter integer H_DEPTH = 6,
    parameter integer B_LEN = 4,
    parameter integer S_LEN = 2

) (
    input logic signed [B_WIDTH-1:0] branch_val [B_LEN-1:0],
    input logic signed [P_WIDTH-1:0] precomp_val [B_LEN-1:0],
    input logic signed [1:0] branch_symbols [B_LEN-1:0],
    input logic [2*B_WIDTH-1:0] state_energy,
    input logic signed [1:0] state_history [H_DEPTH+S_LEN-1:0],

    output logic [2*B_WIDTH-1:0] path_energy,
    output logic signed [1:0] path_history [H_DEPTH+S_LEN+B_LEN-1:0]
);

    assign path_history[B_LEN + H_DEPTH + S_LEN - 1:B_LEN] = state_history;
    assign path_history[B_LEN-1:0] = branch_symbols;

    always_comb begin
        path_energy = state_energy;
        for (int ii = 0; ii < B_LEN; ii += 1) begin
            path_energy += (branch_val[ii] + precomp_val[ii]) ** 2;
        end
    end

endmodule 