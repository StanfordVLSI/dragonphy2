module trellis_pattern_manager #(


) (
    input logic clk,
    input logic rstb,

    input logic signed [1:0] new_trellis_pattern [3:0],
    input logic [1:0] new_trellis_pattern_idx,
    input logic update_trellis_pattern,

    output logic signed [1:0] trellis_patterns [3:0][3:0]
);


always_ff @(posedge clk or negedge rstb) begin
    if (!rstb) begin
        trellis_patterns[0] <= {0, 0, 0, +1};
        trellis_patterns[1] <= {0, 0, -1, +1};
        trellis_patterns[2] <= {-1, 0, 0, +1};
        trellis_patterns[3] <= {-1, +1, -1, +1};
    end else begin
        if (update_trellis_pattern) begin
            trellis_patterns[new_trellis_pattern_idx] <= new_trellis_pattern;
        end
    end
end

endmodule : trellis_pattern_manager