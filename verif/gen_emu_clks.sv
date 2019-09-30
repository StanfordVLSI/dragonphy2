// dragon uses BUFG

module gen_emu_clks #(
    parameter integer n=2
) (
    input wire logic emu_clk_2x,
    output wire logic emu_clk,
    input wire logic clk_vals [n],
    output wire logic clks [n]
);

    // generate emu_clk
    logic emu_clk_unbuf = 0;
    always @(posedge emu_clk_2x) begin
        emu_clk_unbuf <= ~emu_clk_unbuf;
    end
    BUFG buf_emu_clk (.I(emu_clk_unbuf), .O(emu_clk));
    
    // generate other clocks
    logic clk_unbufs [n];
    generate
        for (genvar k=0; k<n; k=k+1) begin : gen_other
            always @(posedge emu_clk_2x) begin
                if (emu_clk_unbuf == 1'b0) begin
                    clk_unbufs[k] <= clk_vals[k];
                end else begin
                    clk_unbufs[k] <= clk_unbufs[k];
                end
            end
            BUFG buf_i (.I(clk_unbufs[k]), .O(clks[k]));
        end
    endgenerate

endmodule
