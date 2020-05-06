/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_supply_dac.sv
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


module mdll_dcdl_supply_dac import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
`ifdef SIMULATION
    input iir_clk,  // not being used in a real implementation
`endif
	input [N_DAC_BW-1:0] ctl_dac_bw_thm,        	// DAC bandwidth control (thermometer)
	input [N_DAC_GAIN-1:0] ctlb_dac_gain_oc,	// r-dac gain control (one cold)
	input [2**N_DAC_TI-1:0] dinb_sel,			// index of vref to vref_out
    output `ANALOG_WIRE vout
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

    //---------------------
    // VARIABLES, WIRES
    //---------------------

`ifndef SIMULATION
	wire ana_vref_out;
`else   // SIMULATION
    real ana_vref_out;
`endif  // ~SIMULATION
    
`ifndef SIMULATION
	genvar k;
	wire [N_DAC_REF-1:0] ana_vref;
    wire [N_DAC_BW-1:0] cap_term;

    
    //---------------------
    // INSTANTIATION
    //---------------------
	
	// somehow, this makes ana_vref[0] connect to 1'b1 and ana_vref[-1] to
	// 1'b0, which is what I wanted.
	generate
		for (k=0;k<N_DAC_REF-1;k++) begin: genblk0
			mdll_psw uRDAC ( .G(1'b0), .S(ana_vref[k]), .D(ana_vref[k+1]) );
		end
	endgenerate


	// gain control switches
	mdll_psw uGAIN_SW0 ( .G(ctlb_dac_gain_oc[0]), .D(1'b0), .S(ana_vref[200]) );
	mdll_psw uGAIN_SW1 ( .G(ctlb_dac_gain_oc[1]), .D(1'b0), .S(ana_vref[180]) );
	mdll_psw uGAIN_SW2 ( .G(ctlb_dac_gain_oc[2]), .D(1'b0), .S(ana_vref[160]) );
	mdll_psw uGAIN_SW3 ( .G(ctlb_dac_gain_oc[3]), .D(1'b0), .S(ana_vref[140]) );

	// decoder
	generate
		for (k=0;k<2**N_DAC_TI;k++) begin: genblk1
			mdll_psw uDEC ( .G(dinb_sel[k]), .S(ana_vref[k]), .D(ana_vref_out) );
		end
	endgenerate

    // decap & its control
    generate
        for (k=0;k<N_DAC_BW;k++) begin: genblk2
            mdll_tbuf uTERM ( .EN(ctl_dac_bw_thm[k]), .Z(cap_term[k]) );
            mdll_decap u_decap[5:0] ( .TOP(ana_vref_out), .BOT(cap_term[k]) );
        end
    endgenerate
`endif // ~SIMULATION

    
    //---------------------
    // COMBINATIONAL
    //---------------------
    
`ifndef SIMULATION
	assign ana_vref[0] = 1'b1;
    assign ana_vref[N_DAC_REF-1] = 1'b0;
`endif // ~SIMULATION


mdll_supply_dac_buffer uSF (
    .ana_vref(ana_vref_out),
    .vout(vout)
);
    
    //---------------------
    // SEQ
    //---------------------
    
    
    //---------------------
    // OTHERS
    //---------------------

    
// synopsys translate_off

    real ana_vref_out_pre;
    real voffset, gain;   // adjustable on-the-fly
    //real vdrv;
	reg [N_DAC_TI-1:0] din; 
	wire [N_DAC_GAIN-1:0] ctl_dac_gain_oh;	
    real Kgain;

    initial begin
        voffset = VDD_DCDL_DAC;
    end
    
    assign ctl_dac_gain_oh = ~ctlb_dac_gain_oc;
    always @(ctl_dac_gain_oh) begin
        case(ctl_dac_gain_oh) 
            4'b0000: Kgain = 1.0;
            4'b0001: Kgain = 2.0;
            4'b0010: Kgain = 3.0;
            4'b0100: Kgain = 4.0;
            4'b1000: Kgain = 5.0;
            default: Kgain = 1.0;
        endcase
    end

    assign gain = LSB0_DCDL_SUPPLY_DAC*Kgain;

	always @(dinb_sel) begin
		for (int m=0;m<2**N_DAC_TI;m++) begin
			if (dinb_sel[m]===1'b0) begin
				din = m;
				break;
			end
		end
	end

    assign ana_vref_out_pre = voffset + gain * din;

    mdll_supply_dac_filter uLPF (
        .iir_clk(iir_clk), 
        .ctl_dac_bw_thm(ctl_dac_bw_thm),
        .vin(ana_vref_out_pre),
        .vout(ana_vref_out)
    );

    // assertion for code encoding
    string msg;
    always @(ctl_dac_gain_oh) begin
		$sformat(msg, "[%m] ctlb_dac_gain_oc(%b) must be one-cold.",ctlb_dac_gain_oc);
        assert ($onehot(ctl_dac_gain_oh)) else $error(msg);
    end

// synopsys translate_on

endmodule

