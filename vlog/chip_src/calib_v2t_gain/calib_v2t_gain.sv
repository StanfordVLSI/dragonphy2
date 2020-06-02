/********************************************************************
filename: calib_v2t_gain.sv

Description:
Calibration circuit of V2T gain. Synthesizable.

Assumptions:

Todo:

********************************************************************/

`include "iotype.sv"

`default_nettype none

module calib_v2t_gain #(

parameter real V2T_jit_rms = 1e-12,
parameter real V2T_offset = 0e-12,
parameter real VDD = 0.8,
parameter real Vcm_AC_max = 0.05,
parameter real Vgain = 0.75,

parameter integer Nv2t=4,
parameter integer Nrange =4,
parameter real DZ_unit_delay = 20e-12,
parameter integer Nunit_DZ = 8
)
(
    input wire logic clk,
    input wire logic rstb,
    input wire logic en_v2t,
    input wire logic en_v2t_cal,
    input wire logic [Nv2t-1:0] ext_v2t_ctl,
    input wire logic [$clog2(Nunit_DZ)-1:0] DZ_v2t,
    input `real_t Vcal,
    output reg [Nv2t-1:0] v2t_ctl
);

// wires, regs

//reg en_v2t_cal_sync;
reg clk_v2t_div2; 
reg tout_div2;
reg arb_out1;
reg arb_out2;

reg [Nv2t-1:0] v2t_ctl_pre;
wire tout;
wire arb_clk1, arb_clk2;
wire [Nunit_DZ-1:0] tout_d;
wire tout_selected;
wire clk_v2t, clkb_v2t, clke_v2t, clkeb_v2t, clkl_v2t, clklb_v2t;
wire [31:0] v2t_ctl_thm;

`pwl_t Vinp = `PWL_ZERO;
assign clkb_v2t = ~clk_v2t;
assign clkeb_v2t = ~clke_v2t;
assign clklb_v2t = ~clkl_v2t;
assign tout_selected = tout_d[DZ_v2t];


//initial begin
//v2t_ctl <= 2**(Nv2t)-1;
//en_v2t_cal_sync <=0;
//clk_v2t_div2 <=0;
//tout_div2<=0;
//end
// replica V2T
//V2T_clockgen #() iV2T_CLKGEN(.clk(clk), .init(2'b00), .en_in(en_v2t), .en_out(), .clk_v2t(clk_v2t), .clk_div(clk_div));
//V2T_CS #( .V2T_jit_rms(V2T_jit_rms), .V2T_offset(V2T_offset), .VDD(VDD), .Vcm_AC_max(Vcm_AC_max), .Vgain(Vgain)) iV2T (.VinP(0.0), .VinN(0.0), .clk(clk_v2t), .ctl(v2t_ctl), .ToutP(tout), .ToutN());


V2T_clock_gen IV2Tclkgen (
    .clk(clk), .init(2'b00), .en_sync_in(en_v2t), .rstb(rstb), .en_slice(1'b1),
    .en_sync_out(),
    .clk_v2tP(clk_v2t),
    .clk_v2tN(),
    .clk_v2tP_e(clke_v2t),
    .clk_v2tN_e(),
    .clk_v2tP_l(clkl_v2t),
    .clk_v2tN_l(),
    .clk_div()
);


V2T IV2Tp ( .V2T_OUT(tout), .CLK(clk_v2t), .CLKB(clkb_v2t), .CLKB_D(clkb_v2t), .CLK_D(clk_v2t),
     .CLKe(clke_v2t), .CLKeB(clkeb_v2t), .CLKl(clkl_v2t), .CLKlB(clklb_v2t), .CLKlB_D(clklb_v2t), .CLKl_D(clkl_v2t),
     .Vcal(Vcal), .Vin(Vinp), .ctl(v2t_ctl_thm) );


bin2thm_5b I118 ( .BIN(v2t_ctl), .TOUT(v2t_ctl_thm));


delay_func #(.del_nom(DZ_unit_delay)) idelay[Nunit_DZ-1:0] (.in({tout_d[Nunit_DZ-2:0],tout_div2}), .out(tout_d));


arbiter_tdc iarb1(.IN2(tout_div2), .IN1(clk_v2t_div2), .EN(1'b1), .CLK(arb_clk1), .OUT(arb_out1));


delay_func #(.del_nom(DZ_unit_delay*2)) idelay1(.in(tout_div2&clk_v2t_div2), .out(arb_clk1));


arbiter_tdc iarb2(.IN2(tout_selected), .IN1(clk_v2t_div2), .EN(1'b1), .CLK(arb_clk2), .OUT(arb_out2));


delay_func #(.del_nom(DZ_unit_delay*2)) idelay2(.in(tout_selected&clk_v2t_div2), .out(arb_clk2));


//always @(posedge clk_v2t) begin
//	en_v2t_cal_sync <= en_v2t_cal;
//end

always_ff @(posedge clk_v2t) 
	if (en_v2t_cal) 
        clk_v2t_div2 <= ~clk_v2t_div2;
	else 
        clk_v2t_div2 <= 1'b0;

always_ff @(posedge tout) 
    if (en_v2t_cal) 
        tout_div2 <= ~tout_div2;
    else 
        tout_div2 <=1'b0;

always_comb begin
    if (~en_v2t_cal) 
        v2t_ctl_pre = ext_v2t_ctl;
    else
	    if (~arb_out1) v2t_ctl_pre = v2t_ctl + 1;
	    else if(arb_out2) v2t_ctl_pre = v2t_ctl - 1;
	    else v2t_ctl_pre = v2t_ctl;
end

always_ff @(negedge clk_v2t_div2, negedge rstb) 
    if (~rstb) 
        v2t_ctl <= '0;
    else 
        v2t_ctl <= v2t_ctl_pre;

endmodule

`default_nettype wire
