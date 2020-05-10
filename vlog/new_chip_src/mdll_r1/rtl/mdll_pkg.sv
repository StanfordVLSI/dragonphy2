/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_pkg.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  -

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/

package mdll_pkg;

// synopsys translate_off

//////////////////////////////
// External env./ PLL config.
//////////////////////////////

    parameter real FREQ_REF = 125e6;  // reference clock frequency
    parameter integer N_FBDIV = 5;    // feedback division ratio (2**N)

    parameter real FREQ_DCO_TARG = (FREQ_REF*2**N_FBDIV);  // target DCO frequency
    parameter real TPER_DCO_TARG = 1.0/FREQ_DCO_TARG;  // target DCO period

// synopsys translate_on

//////////////////////////////
// Design parameters
//////////////////////////////

// FEEDBACK DIVIDER
    parameter int N_DIV = 5; // bit width of feedback divider ratio control 
    
 
// DCDL
	// offset delay; supply modulated by DAC
    parameter int N_DCO_O = 2; // bit width of offset delay that is modulated by supply DAC, FIX TO 2
	// coarse delay; set by FCAL
    //parameter int N_DCO_C = 4; // bit width of coarse control
	// tracking delay
	parameter int N_DCO_TI_MSB = 4;	// bit width of tracking control word (MSB)
	parameter int N_DCO_TI_LSB = 4;	// bit width of tracking control word (LSB)
	parameter int N_PI = N_DCO_TI_LSB;// bit width of PI control
    parameter int N_DCO_TI = (N_DCO_TI_MSB+N_PI); 	// bit width of tracking control (integer)
    parameter int N_DCO_TF = 14; 					// bit width of tracking control (fraction)
    parameter int N_DCO_T = (N_DCO_TI+N_DCO_TF); 	// bit width of tracking control

// DCDL SUPPLY DAC
    parameter int N_DAC_TI = 6;		// bit width of supply DAC, FIXED to 6
    parameter int N_DAC_TF = 14;  	// fractional bit of DAC tracking
    parameter int N_DAC_T = (N_DAC_TI+N_DAC_TF); // bit width of tracking control
    parameter int N_DAC_DITH = 1; // dither width of dac tracking control, FIXED TO 1
    parameter int N_DAC_BW = 7; // bit width of dac loop filter bandwidth (thermometer), FIXED TO 7
    parameter int N_DAC_GAIN = 4;   // bit width of R-DAC gain control (one cold) FIXED TO 4
    parameter int N_DAC_REF = 255;  // # of voltage switch resistors for reference generation

// Digital loop filter
    parameter int N_BB_GB = 4; 	// gain (2**N) for bbpd output
    parameter int N_BB_GDAC = 4; 	// gain (2**N) for bb dac

// AUX OSC
    parameter int N_PH_AUXOSC = 4; // number of phases of the aux oscillator

// FCAL
    parameter int N_FCAL_CNT = 10;  // 2**N is the max divider ratio to generate ref pulse from clk_ref

// JITTER MEAS
    parameter int N_JIT_CNT = 25;  // counter bit width of the jitter measurement 

//////////////////////////////
// Performance parameters
//////////////////////////////

// synopsys translate_off

// REFERENCE CLOCK

    parameter realtime RJ_REF_RMS = 0.0e-12;	// RMS RJ in sec of reference clock

// DCDL 
    //parameter realtime TD0_DCDL = 0ps;
    parameter realtime RJ_DCDL_RMS = 0e-12;
    parameter realtime TD_DCDL_MUX = 10e-12;

// DCDL (COARSE)
    parameter real TD0_DCDL_COARSE_ND2 = 7.0e-12;  // nand2 in coarse delay cell

// DCDL (FINE) Fine DAC
    // tau = DAC_RES*(DAC_C0 + ctl*DAC_CU)
    localparam real DAC_RES = 10e3;     // resistance
    localparam real DAC_CU = 50e-15;    // unit capacitance
    localparam real DAC_C0 = 10e-15;    // offset capacitance

    parameter real VDD_DCDL_DAC = 1.2;    // power supply for DAC
    parameter real VDDNOM_DCDL = 1.0;    // power supply for DCDL
    parameter real V_GS_LDO = (VDD_DCDL_DAC-VDDNOM_DCDL); 
    parameter real LSB0_DCDL_SUPPLY_DAC = -0.0013;//*2**(N_DAC_TI);     // [V/code]

    //parameter real TD0_PI = (TD0_DCDL_COARSE_ND2+3e-12);     // [sec]
    parameter real TD0_PI = 21.6e-12;     // [sec]
    parameter real PI_GAIN = 4.78e-12/TD0_DCDL_COARSE_ND2;   // ideally, the time difference of two incoming clock edges is 2*TD0_DCDL_COARSE_ND2
                                    // this parameter is multiplied to that time difference for the PI to see if that could cause any issue

// PD
    parameter real TD_PFD_RESET = 30e-12;   // reset delay [sec]

// Supply sensitivity of delay
	parameter real KD_VDD = (8.2/12.4);	// 12.4% vdd change -> 8.2% delay change
// AUX
    parameter real FREQ_AUXOSC = 1e9; // Aux oscillator nominal frequency [Hz]

// synopsys translate_on

//////////////////////////////
// Utility function
//////////////////////////////
   
// synopsys translate_off

    let MAX(a,b) = (a>=b) ? a : b ;
    let MIN(a,b) = (a<=b) ? a : b ;
    let ABS(a)   = (a>=0) ? a : -a ;
    let CLOSER(a,b,t) = (ABS(a-t) <= ABS(b-t))? a : b;

// synopsys translate_on

endpackage // mdll_pkg
