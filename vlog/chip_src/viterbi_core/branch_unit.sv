module branch_unit #(
    parameter integer B_WIDTH = 8,
    parameter integer P_WIDTH = 8,
    parameter integer H_DEPTH = 6,
    parameter integer B_LEN = 4,
    parameter integer S_LEN = 2

) (
    input logic clk,

    input logic signed [B_WIDTH-1:0] branch_val [B_LEN-1:0],
    input logic signed [P_WIDTH-1:0] precomp_val [B_LEN-1:0],
    input logic signed [1:0] branch_symbols [B_LEN-1:0],
    input logic [2*B_WIDTH-1:0] state_energy,
    input logic signed [1:0] state_history [H_DEPTH+S_LEN-1:0],

    output logic [2*B_WIDTH-1:0] path_energy,
    output logic signed [1:0] path_history [H_DEPTH+S_LEN+B_LEN-1:0]
);
    import test_pack::*;

    logic signed [B_WIDTH-1:0] total_val [B_LEN-1:0];

    assign path_history[B_LEN + H_DEPTH + S_LEN - 1:B_LEN] = state_history;
    assign path_history[B_LEN-1:0] = branch_symbols;

    logic signed [2*B_WIDTH-1:0] branch_energy;

    always_comb begin
        path_energy = state_energy;
        for (int ii = 0; ii < B_LEN; ii += 1) begin
            total_val[ii] = branch_val[ii] + precomp_val[ii];
            branch_energy = total_val[ii] ** 2;
            path_energy += $unsigned(branch_energy);
        end
    end

    always_ff @(posedge clk) begin
        $display("%m");
        $write("\tbranch_val: ");
        test_pack::array_io#(logic signed [B_WIDTH-1:0], B_LEN)::write_array(branch_val);
        $write("\tprecomp_val: ");
        test_pack::array_io#(logic signed [B_WIDTH-1:0], B_LEN)::write_array(precomp_val);
        $write("\ttotal_val: ");
        test_pack::array_io#(logic signed [B_WIDTH-1:0], B_LEN)::write_array(total_val);
        $write("\tstate_energy: %d\n", state_energy);
        $write("\tpath_energy: %d\n", path_energy);
    end

endmodule 