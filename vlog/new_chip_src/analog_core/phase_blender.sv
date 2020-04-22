module phase_blender (
    input [1:0] ph_in,
    input [15:0] thm_sel_bld,
    output ph_out
);
    // buffer ph_in[0] to ph0
    wire net01, ph0;
    inv iin_buf_odd1_dont_touch ( .in(ph_in[0]), .out(net01));
    inv iin_buf_odd2_dont_touch ( .in(net01), .out(ph0));

    // buffer ph_out[1] to ph1
    wire net02, ph1;
    inv iin_buf_even1_dont_touch ( .in(ph_in[1]), .out(net02));
    inv iin_buf_even2_dont_touch ( .in(net02), .out(ph1));

    // blend ph0 and ph1 into sum
    // TODO: convert to generate or array syntax
    wire sum;
    mux imux_0_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 0]), .out(sum));
    mux imux_1_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 1]), .out(sum));
    mux imux_2_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 2]), .out(sum));
    mux imux_3_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 3]), .out(sum));
    mux imux_4_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 4]), .out(sum));
    mux imux_5_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 5]), .out(sum));
    mux imux_6_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 6]), .out(sum));
    mux imux_7_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 7]), .out(sum));
    mux imux_8_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 8]), .out(sum));
    mux imux_9_dont_touch  ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[ 9]), .out(sum));
    mux imux_10_dont_touch ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[10]), .out(sum));
    mux imux_11_dont_touch ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[11]), .out(sum));
    mux imux_12_dont_touch ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[12]), .out(sum));
    mux imux_13_dont_touch ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[13]), .out(sum));
    mux imux_14_dont_touch ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[14]), .out(sum));
    mux imux_15_dont_touch ( .in0(ph0), .in1(ph1), .sel(thm_sel_bld[15]), .out(sum));

    // buffer sum to ph_out
    wire net03;
    inv iout_buf1_dont_touch ( .in(sum), .out(net03));
    inv iout_buf2_dont_touch ( .in(net03), .out(ph_out));
endmodule

