/********************************************************************
filename: V2T.sv

Description: 
Single-ended S&H and pulse generator
Note that current mismatch is handled in V2TParameter class

Assumptions:
    - This dodesn't model all clock input combinations.

Todo:
    - write more accurate functions at each clock stage

********************************************************************/

`include "mLingua_pwl.vh"
`include "voltage_net.sv"

module V2T import const_pack::*; #(
    parameter real TD_V2T_OFFSET = 0.0
) (
    output reg V2T_OUT,  // output pulse
    input voltage Vcal, // gate bias voltage of a current source
    input pwl Vin,  // input voltage being sampled
    input wire logic clk_v2t,  // sampling clock for the input switch
    input wire logic clk_v2tb, // ~ CLK
    input wire logic clk_v2t_gated,    // ~CLKB_D
    input wire logic clk_v2tb_gated,   // flip Cs polarity right before starting ramp down
    input wire logic clk_v2t_e,     // bottom plate sampling
    input wire logic clk_v2t_eb,    // ~CLKe
    input wire logic clk_v2t_l,     // steer current on the other path, do nothing in this model
    input wire logic clk_v2t_lb,    // ~CLKlB
    input  [2**Nv2t-1:0]  ctl          // ramp current control (thermometer coded)
);

PWLMethod pm=new;
`get_timeunit

// design parameter class instantiation, initialization

V2TParameter v2t_obj;

real Cs_eff;    // effective capacitance considering gain error due to parasitic cap
real Vdch_cm;
real td_v2t_offset;

initial begin
    v2t_obj = new();
    `ifdef RANDOMIZE
        void'(v2t_obj.randomize());
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

assign Iunit = v2t_obj.get_current(Vcal.V);
assign Iramp = Iunit*$countones(ctl);

real Vdch;
// sample&hold 
always @(negedge clk_v2t) begin
    Vin_s = pm.eval(Vin, `get_time);
    Vdch = v2t_obj.Vgain*(Vin_s - VSupl + Vdch_cm) - Vdch_cm;
end

// precharge Vdch to VDD
always @(clk_v2t_e) 
    if (clk_v2t_e) V2T_OUT <= 1'b0;

// create a pulse 
always @(posedge clk_v2t_lb) begin // ramp down
    Vdch = -Vdch;
    V2T_OUT <= 1'b0;
    dt = (Vdch-v2t_obj.Vlth)*Cs_eff/Iramp + v2t_obj.Td_comp + td_v2t_offset + v2t_obj.get_V2T_jitter();
    V2T_OUT <= #(dt*1s) 1'b1;
end

endmodule
