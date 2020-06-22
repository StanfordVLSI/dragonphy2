// simple model used for performance comparison with emulation

`timescale 1s/1fs

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
    logic div_state = 1'b0;
    always @(posedge in) begin
        div_state <= ~div_state;
    end

    assign out = div_state;

    // out_meas is unused
    assign out_meas = 1'b0;
endmodule
