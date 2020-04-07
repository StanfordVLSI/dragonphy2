/********************************************************************
filename: phase_blender_1bit.sv

Description: 
1-bit phase blender.
It either takes the leading clock edge or mid-phase between clocks

Assumptions:

Todo:

********************************************************************/

module phase_blender_1b (
    input wire logic [1:0] ph_in,    // clocks being interpolated
    input wire logic en_mixer,       // '1': phase blend, '0': bypass leading clock
    output reg ph_out                // blended phase
);

timeunit 1fs;
timeprecision 1fs;

import model_pack::*;

//----- SIGNAL DECLARATION -----
real t_lead;
real tdiff;                  // time difference b/t two clock phases
real tout;                   // phase interpolated delay
real wgt;                    // phase interpolation weight
real td, rj;                 // delay of this cell, random jitter
logic sign;                  // indicates which clock leads the other
logic ph_lead;               // selected clock that leads the other
logic ph_in0_d, ph_in1_d;    // delayed signal of ph_in[0], ph_in[1]

//----- FUNCTIONAL DESCRIPTION -----

// design parameter class init
PIParameter pi_obj;

initial begin
    pi_obj = new();
    td = pi_obj.td_mixer1b;
end

// phase interpolation weight
assign wgt = en_mixer ? 0.5 : 0.0;

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
always @(ph_lead) begin
    rj = pi_obj.get_rj_mixer1b();
    if (sign) begin
        ph_out <= #((tout+rj)*1s) ph_in0_d;
    end else begin
        ph_out <= #((tdiff-tout+rj)*1s) ph_in1_d;
    end
end

//always @(del, tdiff, jit) begin
//	assert ( Nblender==0 || del+jit > tdiff || `get_time < 100e-9 ) else $warning("%m: del+jit (%f [psec]) is less than tdiff(%f [psec]) at %f [nsec]", (del+jit)/1e-12, tdiff/1e-12, $realtime*TU*1e9);
//end

endmodule