`timescale 1s/1fs

module test(
    input wire clk_a,
    input wire rst_a,
    output wire out_a,
    input wire clk_b,
    input wire rst_b,
    output wire [15:0] out_b
);

    logic [31:0] init_vals [16];
    assign init_vals[0]  = 32'h0ffd4066;
    assign init_vals[1]  = 32'h38042b00;
    assign init_vals[2]  = 32'h001fffff;
    assign init_vals[3]  = 32'h39fbfe59;
    assign init_vals[4]  = 32'h1ffd40cc;
    assign init_vals[5]  = 32'h3e055e6a;
    assign init_vals[6]  = 32'h03ff554c;
    assign init_vals[7]  = 32'h3e0aa195;
    assign init_vals[8]  = 32'h1f02aa60;
    assign init_vals[9]  = 32'h31f401f3;
    assign init_vals[10] = 32'h00000555;
    assign init_vals[11] = 32'h300bab55;
    assign init_vals[12] = 32'h1f05559f;
    assign init_vals[13] = 32'h3f8afe65;
    assign init_vals[14] = 32'h07ff5566;
    assign init_vals[15] = 32'h7f8afccf;

    prbs_generator_syn #(
        .n_prbs(32)
    ) prbs_a (
        .clk(clk_a),
        .rst(rst_a),
        .cke(1'b1),
        .init_val(32'h00000001),
        .eqn(32'h100002),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(out_a)
    );

    genvar i;
    generate
        for(i=0; i<16; i=i+1) begin
            prbs_generator_syn #(
                .n_prbs(32)
            ) prbs_b (
                .clk(clk_b),
                .rst(rst_b),
                .cke(1'b1),
                .init_val(init_vals[i]),
                .eqn(32'h100002),
                .inj_err(1'b0),
                .inv_chicken(2'b00),
                .out(out_b[i])
            );
        end
    endgenerate

endmodule
