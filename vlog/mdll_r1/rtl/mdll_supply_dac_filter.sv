/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_supply_dac_filter.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Low pass filter at the output of a DCDL supply dac.

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_supply_dac_filter import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
`ifdef SIMULATION
	input iir_clk,				// virtual clock for updating filter
`endif
	input [N_DAC_BW-1:0] ctl_dac_bw_thm, // DAC bandwidth control 
	input `ANALOG_WIRE vin,		// analog input
	output `ANALOG_WIRE vout	// analog output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

`ifndef SIMULATION
	assign vout = vin;
`endif

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

real cap;
real tau;
real fc_in_mhz;
real alpha;

// set dc operating point of the filter output
initial begin 
  vout = vin;
  while(1) begin
    @(vin);
    if ($time==0) vout = vin;
    else break;
  end
end

always @(ctl_dac_bw_thm) begin
    cap = DAC_C0 + real'($countones(ctl_dac_bw_thm))*DAC_CU;
    tau = DAC_RES*cap;
    fc_in_mhz = 1.0/6.28/tau/1e6;
    alpha = TPER_DCO_TARG/(TPER_DCO_TARG+tau);
end

// Describe the low pass filter characteristics as an IIR
always @(posedge iir_clk) begin // freq = FREF_REF*2**N_FBDIV
  vout = alpha*vin + (1.0-alpha)*vout;
end

// synopsys translate_on

endmodule

