module branch_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer P_WIDTH = 8,
    parameter integer B_LEN = 4,
    parameter integer S_LEN = 2,
    parameter logic [S_LEN-1:0] TAG = {S_LEN{1'b1}}

) (
    input logic signed [B_WIDTH-1:0] branch_val [B_LEN-1:0],
    input logic signed [P_WIDTH-1:0] precomp_val [B_LEN-1:0],

    input logic signed [2*B_WIDTH-1:0] state_energy,
    input logic [1:0] state_history [H_DEPTH-1:0]

    output logic [2*B_WIDTH-1:0] path_energy,
    output logic [1:0] path_history [H_DEPTH-1:0]
);

    assign path_history[X:Y] = state_history[X+K:Y+K];
    assign path_history[Y-1:0] = TAG;

    always_comb begin
        path_energy = state_energy;
        for (int ii = 0; ii < B_LEN, ii += 1) begin
            path_energy += (branch_val[ii] + precomp_val[ii]) ** 2;
        end
    end

endmodule 