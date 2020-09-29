/********************************************************************
filename: calib_sample_avg.sv

Description:
Computes the average of 2**Navg samples of din.  The outputs are
held constant while the average is being updated, and change only
when enabled by the "update" signal.

Assumptions:
The "update" signal pulses high once every Navg cycles.

********************************************************************/

`default_nettype none

module calib_sample_avg #(
    parameter integer Nadc=8,
    parameter integer Nrange=4
) (
    input wire logic signed [Nadc-1:0] din,
    input wire logic [Nrange-1:0] Navg,
    input wire logic clk,
    input wire logic update,
    input wire logic rstb,
    output reg signed [Nadc-1:0] avg_out,
    output reg signed [Nadc+2**Nrange-1:0] sum_out
);

//////////////////////
// internal signals //
//////////////////////

logic signed [(Nadc+(2**Nrange)-1):0] sum_pre;
logic signed [(Nadc-1):0] avg_out_pre;
logic signed [(Nadc+(2**Nrange)-1):0] sum_add_din;
logic signed [(Nadc+(2**Nrange)-1):0] sum;

/////////////////
// assignments //
/////////////////

assign sum_add_din = sum + din;
assign sum_pre = update ? din : sum_add_din ;
assign avg_out_pre = sum >>> Navg;

/////////
// sum //
/////////

always @(posedge clk or negedge rstb) begin
    if (!rstb) begin
        sum <= 0;
    end else begin
        sum <= sum_pre;
    end
end

/////////////
// sum_out //
/////////////

always @(posedge clk) begin
    if (!rstb) begin
        sum_out <= '0;
    end else if (update) begin
        sum_out <= sum;
    end else begin
        sum_out <= sum_out;
    end
end

/////////////
// avg_out //
/////////////

always @(posedge clk or negedge rstb) begin
    if (!rstb) begin
        avg_out <= '0;
    end else if (update) begin
        avg_out <= avg_out_pre;
    end else begin
        avg_out <= avg_out;
    end
end

endmodule

`default_nettype wire
