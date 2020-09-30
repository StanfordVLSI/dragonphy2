/********************************************************************
filename: avg_pulse_gen.sv

Description:
Generates a single-cycle pulse once every 2**ndiv clock cycles.
This is used to mark the beginning of a new averaging period.

********************************************************************/

`default_nettype none

module avg_pulse_gen #(
    parameter integer N=4
) (
    input wire logic clk,
    input wire logic rstb,
    input wire logic [(N-1):0] ndiv,
    output reg out
);

    //////////////////////
    // internal signals //
    //////////////////////

    logic [((2**N)-1):0] state;
    logic [((2**N)-1):0] thresh;
    logic is_thresh;

    ///////////////////
    // set threshold //
    ///////////////////

    assign thresh = (1 << ndiv) - 1;
    assign is_thresh = (state == thresh);

    ///////////////////////////
    // update internal state //
    ///////////////////////////

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            state <= 0;
        end else if (is_thresh) begin
            state <= 0;
        end else begin
            state <= state + 1;
        end
    end

    //////////////////
    // drive output //
    //////////////////

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            out <= 1'b0;
        end else begin
            out <= is_thresh;
        end
    end

endmodule

`default_nettype wire
