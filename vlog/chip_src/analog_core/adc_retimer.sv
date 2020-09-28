/********************************************************************
filename: adc_retimer.sv

Description:
Samples the inputs and produces outputs that are registered to the
the rising edge of clk_retimer.
********************************************************************/

`default_nettype none

module adc_retimer #(
    parameter integer Nadc=8
) (
    input wire logic clk_retimer,

    input wire logic [(Nadc-1):0] in_data,
    input wire logic in_sign,

    output wire logic [(Nadc-1):0] out_data,
    output wire logic out_sign,

    input wire logic mux_ctrl_1,
    input wire logic mux_ctrl_2
);

    // Positive latch

    logic [(Nadc-1):0] pos_latch;
    logic pos_latch_sign;

    always_latch begin
        if(clk_retimer) begin
            pos_latch      <= in_data;
            pos_latch_sign <= in_sign;
        end
    end

    // Mux 1

    logic [(Nadc-1):0] mux_out_1;
    logic mux_out_1_sign;

    assign mux_out_1      = mux_ctrl_1 ? in_data : pos_latch;
    assign mux_out_1_sign = mux_ctrl_1 ? in_sign : pos_latch_sign;

    // Flip-flop 1

    logic [(Nadc-1):0] pos_flop_1;
    logic pos_flop_1_sign;

    always_ff @(posedge clk_retimer) begin
        pos_flop_1      <= mux_out_1;
        pos_flop_1_sign <= mux_out_1_sign;
    end

    // Flip-flop 2

    logic [(Nadc-1):0] pos_flop_2;
    logic pos_flop_2_sign;

    always_ff @(posedge clk_retimer) begin
        pos_flop_2      <= pos_flop_1;
        pos_flop_2_sign <= pos_flop_1_sign;
    end

    // Mux 2

    logic [(Nadc-1):0] mux_out_2;
    logic mux_out_2_sign;

    assign mux_out_2      = mux_ctrl_2 ? pos_flop_1      : pos_flop_2;
    assign mux_out_2_sign = mux_ctrl_2 ? pos_flop_1_sign : pos_flop_2_sign;

    // Assign outputs

    assign out_data = mux_out_2;
    assign out_sign = mux_out_2_sign;

endmodule

`default_nettype wire
