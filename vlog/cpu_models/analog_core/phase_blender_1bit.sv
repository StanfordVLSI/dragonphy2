/********************************************************************
filename: phase_blender_1bit.sv

Description: 
1-bit phase blender.
It either takes the leading clock edge or mid-phase between clocks

Assumptions:

Todo:

********************************************************************/

`default_nettype none

module phase_blender_1bit import const_pack::*; (
// I/Os here
    input wire logic ph_in1, ph_in0,  // two clocks being interpolated 
    input wire logic en_mixer,      // '1': phase blend, '0': bypass leading clock
    output reg ph_out               // blended phase
);

timeunit 1fs;
timeprecision 1fs;

real TU = 1/1s; // verilog time unit in sec

//----- SIGNAL DECLARATION -----
real t_lead;
real tdiff; // time difference b/t two clock phases
real tout;  // phase interpolated delay
real wgt;       // phase interpolation weight
real td, rj;    // delay of this cell, random jitter
logic sign;     // indicates which clock leads the other
logic ph_lead;  // selected clock that leads the other
logic ph_in0_d, ph_in1_d;   // delayed signal of ph_in[0], ph_in[1]
wire logic [1:0] ph_in = {ph_in1, ph_in0};

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
always @(ph_in[0])  ph_in0_d <= #(td*1s) ph_in[0];
always @(ph_in[1])  ph_in1_d <= #(td*1s) ph_in[1];

// find which clock input leads
always @(ph_in[0])  sign <= ph_in[0] ^ ph_in[1];
assign ph_lead = sign ? ph_in0_d : ph_in1_d; 

// compute the phase difference
always @(ph_in) begin
    if (ph_in[0] ^ ph_in[1]) 
        t_lead = `get_time;
    else begin
        tdiff = `get_time - t_lead;
        tout = tdiff * wgt;
    end
end

// phase interpolation
always @(ph_lead) begin
    rj = pi_obj.get_rj_mixer1b();
    if (sign)   ph_out <= `delay(tout+rj)       ph_in0_d;
    else        ph_out <= `delay(tdiff-tout+rj) ph_in1_d;
end


//always @(del, tdiff, jit) begin
//	assert ( Nblender==0 || del+jit > tdiff || `get_time < 100e-9 ) else $warning("%m: del+jit (%f [psec]) is less than tdiff(%f [psec]) at %f [nsec]", (del+jit)/1e-12, tdiff/1e-12, $realtime*TU*1e9);
//end

endmodule

`default_nettype wire
