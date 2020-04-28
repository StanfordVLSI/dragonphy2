module arbiter (
    input in1,
    input in2,
    input clk,
    output reg out,
    output out_dmm
);
//synopsys dc_script_begin
//set_dont_touch {Q Qb in*}
//synopsys dc_script_end

    wire Q, Qb, Q_inv, Qb_inv;

    n_and_arb_fixed inand1_dont_touch (
        .in1(in1),
        .in2(Qb),
        .out(Q)
    );

    n_and_arb_fixed inand2_dont_touch (
        .in1(in2),
        .in2(Q),
        .out(Qb)
    );

    inv_arb_fixed iinv_arb_dont_touch (.in(Q), .out(Q_inv));
    inv_arb_fixed iinv_arb_dmm_dont_touch (.in(Qb), .out(out_dmm));
    
    always @(posedge clk) begin
        out <= Q_inv;
    end

endmodule


