module input_divider (
    input wire logic in,
    input wire logic in_mdll,
    input wire logic sel_clk_source,
    input wire logic en,
    input wire logic en_meas,
    input wire logic [2:0] ndiv,
    input wire logic bypass_div,
    input wire logic bypass_div2,
    output wire logic out,
    output wire logic out_meas
);

    // simplistic model
    assign out = in;
    assign out_meas = in;

endmodule

