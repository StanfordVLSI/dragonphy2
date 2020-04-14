

module biasgen ( Vbias, ctl, en );
  input [3:0] ctl;
  input en;
  output Vbias;
  wire   n_logic0_, net_tied, end0, net10, endb;
  wire   [14:0] ctl_thmb;
  wire   [14:0] ctl_thm;

  assign clt_thmb = ~ctl_thm;
  
  
  n_and4 in_and4_dont_touch[4:0] ( .in1(n_logic0_), .in2(ctl_thmb[4:0]), .in3(ctl_thmb[9:5]), .in4(ctl_thmb[14:10]), .out(net_tied) );
  n_and in_and_dont_touch[11:0] ( .in1(end0), .in2(net_tied), .out(net_tied) );
 
  inv I8_dont_touch ( .I(en), .out(net10) );
  inv I7_dont_touch ( .I(net10), .out(end0) );
  inv I6_dont_touch ( .I(end0), .out(endb) );
  
  bin2thm_4b I11 ( .bin(ctl), .thm(ctl_thm) );
  SW iSW_dont_touch ( .OUT(Vbias), .CLK(end0), .CLKB(endb), .IN(net_tied) );
  tiel itiel ( .out(n_logic0_) );
endmodule

