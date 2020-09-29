/********************************************************************
filename: stochastic_adc.sv

Description: 
Removes the PFD offset from ADC magnitude/sign outputs, producing
a signed integer as the output.  A histogram-based calibration
method is included; it is also possible to provide the estimate
of PFD offset externally.

********************************************************************/

`default_nettype none

module adc_unfolding #(
    parameter integer Nadc=8,
    parameter integer Nrange=4
) (
    input wire logic clk,
    input wire logic rstb,
    input wire logic update,
    input wire logic [Nadc-1:0] din,
    input wire logic sign_out,
	
    input wire logic en_pfd_cal,
    input wire logic en_ext_pfd_offset,
    input wire logic [Nadc-1:0] ext_pfd_offset,
    input wire logic [Nrange-1:0] Nbin,
    input wire logic [Nrange-1:0] Navg,
    input wire logic [Nrange-1:0] DZ,
	
    output reg signed [Nadc-1:0] dout,
    output reg signed [Nadc-1:0] dout_avg,
    output reg signed [Nadc+2**Nrange-1:0] dout_sum,
    output reg [2**Nrange-1:0] hist_center,
    output reg [2**Nrange-1:0] hist_side,
    output reg signed [Nadc-1:0] pfd_offset
);

//////////////////////
// internal signals //
//////////////////////

wire signed [1:0] hist_comp_out;
wire signed [Nadc-1:0] pfd_offset_pre;
wire signed [Nadc:0]  dout_pre1a, dout_pre2a, dout_pre1b, dout_pre2b;
wire signed [Nadc-1:0] dout_pre;
wire signed [Nadc-1:0] pfd_offset_add_hist_comp_out;

///////////////
// averaging //
///////////////

calib_sample_avg #(
    .Nadc(Nadc),
    .Nrange(Nrange)
) iavg (
    .rstb(rstb),
    .din(dout),
    .clk(clk),
    .update(update),
    .Navg(Navg),
    .avg_out(dout_avg),
    .sum_out(dout_sum)
);

///////////////
// histogram //
///////////////

calib_hist_measure #(
    .Nadc(Nadc),
    .Nrange(Nrange)
) ihist (
    .rstb(rstb),
    .din(dout),
    .din_avg(dout_avg),
    .clk(clk),
    .update(update),
    .Nbin(Nbin),
    .DZ(DZ),
    .hist_center(hist_center),
    .hist_side(hist_side),
    .hist_comp_out(hist_comp_out)
); 

///////////////////////////
// pfd offset estimation //
///////////////////////////

assign pfd_offset_add_hist_comp_out = pfd_offset + hist_comp_out; // TODO: have this saturate
assign pfd_offset_pre = en_pfd_cal ? pfd_offset_add_hist_comp_out : ext_pfd_offset;

always @(posedge clk or negedge rstb) begin
    if (~rstb) begin
        pfd_offset <= '0;
    end else if (update) begin
        pfd_offset <= pfd_offset_pre;
    end else begin
	    pfd_offset <= pfd_offset;
    end
end

//////////////////////
// output unfolding //
//////////////////////

assign dout_pre1a = sign_out ? (din - ext_pfd_offset) : (ext_pfd_offset - din);
assign dout_pre2a = sign_out ? (din - pfd_offset) : (pfd_offset - din);
assign dout_pre1b = (dout_pre1a > +9'sd127) ? +9'sd127 :  ((dout_pre1a < -9'sd128) ? -9'sd128 : dout_pre1a);
assign dout_pre2b = (dout_pre2a > +9'sd127) ? +9'sd127 :  ((dout_pre2a < -9'sd128) ? -9'sd128 : dout_pre2a);
assign dout_pre = en_ext_pfd_offset ? dout_pre1b[7:0] : dout_pre2b[7:0];

always @(posedge clk) begin
    dout <= dout_pre;
end

endmodule

`default_nettype wire
