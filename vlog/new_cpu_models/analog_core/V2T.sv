/********************************************************************
filename: V2T.sv

Description: 
Single-ended S&H and pulse generator
Note that current mismatch is handled in V2TParameter class

Assumptions:
    - This doesn't model all clock input combinations.

Todo:
    - write more accurate functions at each clock stage

********************************************************************/

`include "mLingua_pwl.vh"
`timescale 1fs / 1fs

module V2T import const_pack::*; #(
    parameter real TD_V2T_OFFSET = 0.0
) (
    output reg v2t_out,                 // output pulse
    input real Vcal,                    // gate bias voltage of a current source
    input pwl Vin,                      // input voltage being sampled
    input wire logic clk_v2t,           // sampling clock for the input switch
    input wire logic clk_v2tb,          // ~ CLK
    input wire logic clk_v2t_gated,     // ~CLKB_D
    input wire logic clk_v2tb_gated,    // flip Cs polarity right before
                                        // starting ramp down
    input wire logic clk_v2t_e,         // bottom plate sampling
    input wire logic clk_v2t_eb,        // ~CLKe
    input wire logic clk_v2t_l,         // steer current on the other path,
                                        // (does nothing in this model)
    input wire logic clk_v2t_lb,        // ~CLKlB
    input  [2**Nv2t-1:0]  ctl           // ramp current control (thermometer coded)
);

import model_pack::V2TParameter;
import model_pack::VSupl;

PWLMethod pm=new;
`get_timeunit

// design parameter class instantiation, initialization

V2TParameter v2t_obj = new;

real Cs_eff;    // effective capacitance considering gain error due to parasitic cap
real Vdch_cm;
real td_v2t_offset;

initial begin
    `ifdef RANDOMIZE
        td_v2t_offset = v2t_obj.Td_V2T_offset;
    `else
        td_v2t_offset = TD_V2T_OFFSET;
    `endif
    Cs_eff = v2t_obj.Cs/v2t_obj.Vgain;
    Vdch_cm = VSupl - (VSupl/4.0 + v2t_obj.Vcm_AC_max);
end

// wires, state variables

real Iunit; // unit ramp current source
real Iramp; // total ramp current
real dt;    // pulse width
real Vin_s; // sampled input voltage (debugging purpose)

///////////////////
// MODEL BODY
///////////////////

assign Iunit = v2t_obj.get_current(Vcal);
assign Iramp = Iunit*$countones(ctl);

real Vdch;
// sample&hold 
always @(negedge clk_v2t) begin
    Vin_s = pm.eval(Vin, `get_time);
    Vdch = v2t_obj.Vgain*(Vin_s - VSupl + Vdch_cm) - Vdch_cm;
end

// precharge Vdch to VDD
always @(clk_v2t_e) begin
    if (clk_v2t_e) begin
        v2t_out <= 1'b0;
    end
end

// create a pulse 
always @(posedge clk_v2t_lb) begin // ramp down
    Vdch = -Vdch;
    v2t_out <= 1'b0;
    dt = 0.0;
    dt = dt + (Vdch-v2t_obj.Vlth)*Cs_eff/Iramp;
    dt = dt + v2t_obj.Td_comp;
    dt = dt + td_v2t_offset;
    dt = dt + v2t_obj.get_V2T_jitter();
    v2t_out <= #(dt*1s) 1'b1;
end

endmodule
