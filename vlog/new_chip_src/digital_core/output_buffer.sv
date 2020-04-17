

module output_buffer ( clock_out_n, clock_out_p, trigg_out_n, trigg_out_p, Ndiv_outbuff, Ndiv_trigbuff, bufferend_signals, bypass_out_div, bypass_trig_div, en_outbuff, en_trigbuff, sel_outbuff, sel_trigbuff );

  input [2:0] Ndiv_outbuff;
  input [2:0] Ndiv_trigbuff;
  input [15:0] bufferend_signals;
  input [3:0] sel_outbuff;
  input [3:0] sel_trigbuff;
  input bypass_out_div, bypass_trig_div, en_outbuff, en_trigbuff;
  output clock_out_n, clock_out_p, trigg_out_n, trigg_out_p;

  output_buffer_single iout_buffer_single_trig_dont_touch ( .outn(trigg_out_n), .outp(trigg_out_p), .bypass_div(bypass_trig_div), .in(bufferend_signals), .ndiv(Ndiv_trigbuff), .rstb(en_trigbuff), .sel(sel_trigbuff) );
  output_buffer_single iout_buffer_single_out_dont_touch ( .outn(clock_out_n), .outp(clock_out_p), .bypass_div(bypass_out_div), .in(bufferend_signals), .ndiv(Ndiv_outbuff), .rstb(en_outbuff), .sel(sel_outbuff) );

endmodule

