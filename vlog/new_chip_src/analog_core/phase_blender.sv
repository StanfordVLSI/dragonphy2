module phase_blender (
    input [1:0] ph_in,
    input [15:0] thm_sel_bld,
    output ph_out
);

//synopsys dc_script_begin
//set_dont_touch { mid* sum ph0 ph1 ph_out}
//synopsys dc_script_end

    // buffer ph_in[0] to ph0
    inv_bld_1_fixed iin_buf_odd1_dont_touch ( .in(ph_in[0]), .out(mid_in0));
    inv_bld_2_fixed iin_buf_odd2_dont_touch ( .in(mid_in0), .out(ph0));

    // buffer ph_out[1] to ph1
    inv_bld_1_fixed iin_buf_even1_dont_touch ( .in(ph_in[1]), .out(mid_in1));
    inv_bld_2_fixed iin_buf_even2_dont_touch ( .in(mid_in1), .out(ph1));

    // blend ph0 and ph1 into sum
    mux_bld_fixed imux_bld_dont_touch[15:0]  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[15:0]), .out(sum));
    
    // buffer sum to ph_out
    inv_bld_3_fixed iout_buf1_dont_touch ( .in(sum), .out(mid_out));
    inv_bld_3_fixed iout_buf2_dont_touch ( .in(mid_out), .out(ph_out));

endmodule

