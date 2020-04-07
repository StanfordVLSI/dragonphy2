/********************************************************************
filename: delay_pi.sv

Description: 
a delay cell in PI

Assumptions:

Todo:

********************************************************************/

`default_nettype none

module inc_delay import const_pack::*; (
    input wire logic in,        // input signal
    input wire logic del_inc,	// (Act. high) increse the delay by a factor of gain
    output reg out              // delayed output signal
);

// design parameter class

PIParameter pi_obj;


// variables

real td;    // delay w/o jitter 
real td0;   // delay w/o jitter when del_inc=0
real gain;  // delay gain by del_inc
real rj;    // random jitter 


// initialize class parameters
initial begin
    pi_obj = new();
    void'(pi_obj.randomize()); // randomization is must in this block
    td0 = pi_obj.td_chain_unit ;
    gain = pi_obj.td_chain_unit_gain;
end


///////////////////////////
// Model Body
///////////////////////////

// delay control
assign td = del_inc ? td0*gain : td0;

// delay behavior from `in` to `out`
always @(in) begin
    rj = pi_obj.get_rj_chain_unit();
    out <= #((td+rj)*1s) in ;
end

endmodule

`default_nettype wire