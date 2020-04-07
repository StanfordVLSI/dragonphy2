/********************************************************************
filename: phase_blender.sv

Description: 
multi-bit phase blender.

Assumptions:

Todo:

********************************************************************/

module phase_blender #(
  parameter integer Nblender = 4,      // # of control bits
  parameter real del_nom = 100e-12,    // intrinsic delay
  parameter real del_std = 0e-12,
  parameter real jit_rms = 0e-15
) (
    input wire logic [1:0] ph_in,                   // two clocks being interpolated
    input wire logic [2**Nblender-1:0] thm_sel_bld, // interpolation weight (thermometer coded)
    output reg ph_out                               // blended clock
);

timeunit 1fs;
timeprecision 1fs;

import model_pack::PIParameter;

//----- VARIABLE/SIGNAL DECLARATION -----
integer sel_bld_bin;         // binary value of thm_sel_bld
real t_lead;
real tdiff;                  // time difference b/t two clock phases
real tout;                   // phase interpolated delay
real wgt;                    // phase interpolation weight
real td, rj;                 // delay of this cell, random jitter
logic sign;                  // indicates which clock leads the other
logic ph_lead;               // selected clock that leads the other
logic ph_in0_d, ph_in1_d;    // delayed signal of ph_in[0], ph_in[1]
real lut [17];               // interpolation weight LUT

initial begin
    lut[0]=0.0;
    lut[1]=0.0625;
    lut[2]=0.125;
    lut[3]=0.1875;
    lut[4]=0.25;
    lut[5]=0.3125;
    lut[6]=0.375;
    lut[7]=0.4375;
    lut[8]=0.5;
    lut[9]=0.5625;
    lut[10]=0.625;
    lut[11]=0.6875;
    lut[12]=0.75;
    lut[13]=0.8125;
    lut[14]=0.875;
    lut[15]=0.9375;
    lut[16]=1.0;
end

//----- FUNCTIONAL DESCRIPTION -----

// design parameter class init
PIParameter pi_obj;

initial begin
    pi_obj = new();
    td = pi_obj.td_mixermb;
end

// phase interpolation weight
assign sel_bld_bin = $countones(thm_sel_bld) ;

`ifdef LUT
    assign wgt = real'(lut[sel_bld_bin]) ;
`else
    assign wgt = real'(sel_bld_bin)/2.0**Nblender ;
`endif

// delay two inputs
always @(ph_in[0]) begin
    ph_in0_d <= #(td*1s) ph_in[0];
end
always @(ph_in[1]) begin
    ph_in1_d <= #(td*1s) ph_in[1];
end

// find which clock input leads
// TODO: why is this assignment non-blocking?
always @(ph_in[0]) begin
    sign <= ph_in[0] ^ ph_in[1];
end
assign ph_lead = sign ? ph_in0_d : ph_in1_d;

// compute the phase difference
always @(ph_in) begin
    if (ph_in[0] ^ ph_in[1]) begin
        t_lead = ($realtime/1s);
    end else begin
        tdiff = ($realtime/1s) - t_lead;
        tout = tdiff * wgt;
    end
end

// phase interpolation
always @(*) begin
    rj = pi_obj.get_rj_mixermb();
    if (sign) begin
        ph_out <= #((tout+rj)*1s) ph_in0_d;
    end else begin
        ph_out <= #((tdiff-tout+rj)*1s) ph_in1_d;
    end
end

endmodule