/********************************************************************
filename: calib_sample_avg.sv

Description: 
ADC calibration block. To be synthesized.
Assumptions:

Todo:

********************************************************************/

`default_nettype none

module calib_sample_avg import const_pack::*; (
    input wire logic signed [Nadc-1:0] din,
    input wire logic [Nrange-1:0] Navg,
    input wire logic clk,
    input wire logic update,  // assum it's synced to clk
    input wire logic rstb,
    output reg signed [Nadc-1:0] avg_out,
    output reg signed [Nadc+2**Nrange-1:0] sum_out
);



// wires, registers
wire signed [Nadc+2**Nrange-1:0] sum_pre;
wire signed [Nadc-1:0] avg_out_pre;
wire signed [Nadc + 2**Nrange-1:0] sum_add_din;
reg signed [Nadc+2**Nrange-1:0] sum;

assign sum_add_din = sum + din;
assign sum_pre = update ? '0 : sum_add_din ;
assign avg_out_pre = sum >>> Navg;

always @(posedge clk, negedge rstb) 
    if (!rstb) sum <= 0;
    else sum <= sum_pre;

always @(posedge clk) 
    if (update) sum_out <= sum;

always @(posedge clk, negedge rstb) 
    if (!rstb) avg_out <= '0;
    else if (update) avg_out <= avg_out_pre;

endmodule

`default_nettype wire
