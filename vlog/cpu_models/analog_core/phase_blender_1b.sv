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
    output reg ph_out=1'b0           // blended phase
);

    timeunit 1fs;
    timeprecision 1fs;

    import model_pack::PIParameter;

    // design parameter class init
    PIParameter pi_obj;
    real td;
    initial begin
        pi_obj = new();
        td = pi_obj.td_mixer1b;
    end

    // phase interpolation weight
    real wgt;
    assign wgt = en_mixer ? 0.5 : 0.0;

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
                ttotr0 = wgt*(rise1-rise0) + td + pi_obj.get_rj_mixer1b();
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
                ttotf0 = wgt*(fall1-fall0) + td + pi_obj.get_rj_mixer1b();
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
                ttotr1 = (1.0-wgt)*(rise0-rise1) + td + pi_obj.get_rj_mixer1b();
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
                ttotf1 = (1.0-wgt)*(fall0-fall1) + td + pi_obj.get_rj_mixer1b();
            end else begin
                ttotf1 = td + pi_obj.get_rj_mixer1b();
            end
            ph_out <= #(ttotf1*1s) 1'b0;
        end
        fall1 = $realtime/1s;
    end
endmodule