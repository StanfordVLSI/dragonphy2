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

    // state variables
    logic nxt_state=1'b0;
    real rise0=-1;
    real fall0=-1;
    real rise1=-1;
    real fall1=-1;

    real ttotr0;
    always @(posedge ph_in[0]) begin
        if (nxt_state != 1'b1) begin
            // update nxt_state
            nxt_state = 1'b1;
            // calculate delay
            if ((rise0 != -1) && (rise1 != -1) && (rise1 >= rise0)) begin
                ttotr0 = wgt*(rise1-rise0) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotr0 = td + pi_obj.get_rj_mixer1b();
            end
            // schedule output
            ph_out <= #(ttotr0*1s) 1'b1;
        end
        rise0 = $realtime/1s;
    end

    real ttotf0;
    always @(negedge ph_in[0]) begin
        if (nxt_state != 1'b0) begin
            nxt_state = 1'b0;
            if ((fall0 != -1) && (fall1 != -1) && (fall1 >= fall0)) begin
                ttotf0 = wgt*(fall1-fall0) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotf0 = td + pi_obj.get_rj_mixer1b();
            end
            ph_out <= #(ttotf0*1s) 1'b0;
        end
        fall0 = $realtime/1s;
    end

    real ttotr1;
    always @(posedge ph_in[1]) begin
        if (nxt_state != 1'b1) begin
            // update nxt_state
            nxt_state = 1'b1;
            // calculate delay
            if ((rise0 != -1) && (rise1 != -1) && (rise0 >= rise1)) begin
                ttotr1 = (1.0-wgt)*(rise0-rise1) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotr1 = td + pi_obj.get_rj_mixer1b();
            end
            // schedule output
            ph_out <= #(ttotr1*1s) 1'b1;
        end
        rise1 = $realtime/1s;
    end

    real ttotf1;
    always @(negedge ph_in[1]) begin
        if (nxt_state != 1'b0) begin
            nxt_state = 1'b0;
            if ((fall0 != -1) && (fall1 != -1) && (fall0 >= fall1)) begin
                ttotf1 = (1.0-wgt)*(fall0-fall1) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotf1 = td + pi_obj.get_rj_mixer1b();
            end
            ph_out <= #(ttotf1*1s) 1'b0;
        end
        fall1 = $realtime/1s;
    end
endmodule