module phase_blender_1b (
    input [1:0] ph_in,
    input en_mixer,
    output ph_out
);
    // en_mixer=0: pass ph_in[0] through to output
    // en_mixer=1: blend ph_in[0] and ph_in[1] with a 50% ratio
//synopsys dc_script_begin
//set_dont_touch {ph_out}
//synopsys dc_script_end


    mux_fixed IMUX0_dont_touch (
        .in0(ph_in[0]),
        .in1(ph_in[1]),
        .out(ph_out),
        .sel(en_mixer)
    );

    mux_fixed IMUX1_dont_touch (
        .in0(ph_in[0]),
        .in1(1'b0),
        .out(ph_out),
        .sel(1'b0)
    );
endmodule


