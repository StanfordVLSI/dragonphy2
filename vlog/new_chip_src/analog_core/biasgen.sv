

module biasgen ( Vbias, ctl, en );
  input [3:0] ctl;
  input en;
  output Vbias;
  wire   net_tied, end0, net10, endb;
  wire   [14:0] ctl_thmb;
  wire   [14:0] ctl_thm;

 //synopsys dc_script_begin
 //set_dont_touch {*mid* end* net_tied}
 //synopsys dc_script_end
  
 inv iinv[14:0] (.in(ctl_thm), .out(ctl_thmb));
 
  n_and4 in_and4_dont_touch[4:0] ( .in1(1'b0), .in2(ctl_thmb[4:0]), .in3(ctl_thmb[9:5]), .in4(ctl_thmb[14:10]), .out(net_tied) );
  n_and in_and[11:0] ( .in1(end0), .in2(net_tied), .out(net_tied) );
 
  inv ien_buff_1 ( .in(en), .out(en_mid) );
  inv ien_buff_2 ( .in(en_mid), .out(end0) );
  inv ien_buff_3 ( .in(end0), .out(endb) );
  
  bin2thm #(.Nbit(4)) ibin2thm( .bin(ctl), .thm(ctl_thm) );
  SW iSW_dont_touch ( .OUT(Vbias), .CLK(end0), .CLKB(endb), .IN(net_tied) );
endmodule

