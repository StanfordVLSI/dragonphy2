module arbiter (
    input in1,
    input in2,
    input clk,
    output reg out,
    output out_dmm
);

    wire Q, Qb, Q_inv, Qb_inv;

    n_and inand1_dont_touch (
        .in1(in1),
        .in2(Qb),
        .out(Q)
    );

    n_and inand2_dont_touch (
        .in1(in2),
        .in2(Q),
        .out(Qb)
    );

    assign Q_inv = ~Q;
    assign out_dmm= ~Qb;

    always @(posedge clk) begin
        out <= Q_inv;
    end

endmodule


