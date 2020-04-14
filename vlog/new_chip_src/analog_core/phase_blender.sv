

module phase_blender ( ph_in, thm_sel_bld, ph_out );
  input [1:0] ph_in;
  input [15:0] thm_sel_bld;
  output ph_out;
  wire   net01, ph0, net02, ph1, sum, net03; 

  inv iin_buf_odd1_dont_touch ( .in(ph_in[0]), .out(net01));
  inv iin_buf_odd2_dont_touch ( .in(net01), .out(ph0));
  inv iin_buf_even1_dont_touch ( .in(ph_in[1]), .out(net02));
  inv iin_buf_even2_dont_touch ( .in(net02), .out(ph1));
  mux imux_0_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[0]), .Z(sum));
  mux imux_1_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[1]), .Z(sum));
  mux imux_2_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[2]), .Z(sum));
  mux imux_3_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[3]), .Z(sum));
  mux imux_4_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[4]), .Z(sum));
  mux imux_5_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[5]), .Z(sum));
  mux imux_6_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[6]), .Z(sum));
  mux imux_7_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[7]), .Z(sum));
  mux imux_8_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[8]), .Z(sum));
  mux imux_9_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[9]), .Z(sum));
  mux imux_10_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[10]), .Z(sum));
  mux imux_11_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[11]), .Z(sum));
  mux imux_12_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[12]), .Z(sum));
  mux imux_13_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[13]), .Z(sum));
  mux imux_14_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[14]), .Z(sum));
  mux imux_15_dont_touch ( .in1(ph0), .in2(ph1), .S(thm_sel_bld[15]), .Z(sum));
  inv iout_buf1_dont_touch ( .in(sum), .out(net03));
  inv iout_buf2_dont_touch ( .in(net03), .out(ph_out));

endmodule

