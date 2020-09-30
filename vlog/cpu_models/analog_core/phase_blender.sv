/********************************************************************
filename: phase_blender.sv

Description: 
multi-bit phase blender.

Assumptions:

Todo:

********************************************************************/

module phase_blender #(
  parameter integer Nblender = 4                       // # of control bits
) (
    // inputs
    input wire logic [1:0] ph_in,                      // two clocks being interpolated
    input wire logic [2**Nblender-1:0] thm_sel_bld,    // interpolation weight
                                                       // (thermometer coded)
    // outputs
    output reg ph_out                                  // blended clock
);
    timeunit 1fs;
    timeprecision 1fs;

    import model_pack::PIParameter;

    // design parameter class init
    PIParameter pi_obj;
    real td;
    initial begin
        pi_obj = new();
        td = pi_obj.td_mixermb;
    end

    // phase interpolation weight
    real wgt;
    `ifndef LUT
        integer sel_bld_bin;
        assign sel_bld_bin = $countones(thm_sel_bld);
        assign wgt = real'(sel_bld_bin)/2.0**Nblender;
    `else
        real lut [17];
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
        assign wgt = real'(lut[sel_bld_bin]) ;
    `endif

// fixed blender error by sjkim85 (3th May 2020) ------------------------------------------------
real rise_lead;	
real rise_lag;	
real fall_lead;	
real fall_lag;	
real rise_diff_in;
real fall_diff_in;
real ttotr;
real ttotf;
real flip;

	assign ph_and = ph_in[0]&ph_in[1];
	assign ph_or = ph_in[0]|ph_in[1];
	
	always @(posedge ph_in[0]) flip = ph_in[1];
	always @(negedge ph_in[0]) flip = ~ph_in[1];

	always @(posedge ph_or) begin
		rise_lead = $realtime/1s;
	end
	always @(posedge ph_and) begin
		rise_lag = $realtime/1s;
		rise_diff_in = rise_lag - rise_lead;
		ttotr = (flip+(1-2*flip)*wgt)*rise_diff_in + td + pi_obj.get_rj_mixermb() - rise_diff_in;
        ph_out <= #(ttotr*1s) 1'b1;
	end
	always @(negedge ph_and) begin
		fall_lead = $realtime/1s;
	end
	always @(negedge ph_or) begin
		fall_lag = $realtime/1s;
		fall_diff_in = fall_lag - fall_lead;
		ttotf = (flip+(1-2*flip)*wgt)*fall_diff_in + td + pi_obj.get_rj_mixermb() - fall_diff_in;
        ph_out <= #(ttotf*1s) 1'b0;
	end


//---------------------------------------------- ------------------------------------------------
		
endmodule
