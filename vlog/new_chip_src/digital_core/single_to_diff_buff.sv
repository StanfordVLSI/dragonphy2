
module single_to_diff_buff ( OUTN, OUTP, IN );
  input IN;
  output OUTN, OUTP;
  wire   net9, net12, net10;

  inv I14 ( .in(net2), .out(net1) );
  inv I12 ( .in(IN), .out(net1) );
  inv I11_0_ ( .in(net9), .out(OUTN) );
  inv I11_1_ ( .in(net9), .out(OUTN) );
  inv I5_0_ ( .in(net12), .out(OUTP) );
  inv I5_1_ ( .in(net12), .out(OUTP) );
  inv I9 ( .in(net5), .out(net9) );
  inv I4 ( .in(net6), .out(net12) );
  inv I8 ( .in(net3), .out(net5) );
  inv I3 ( .in(net4), .out(net6) );
  inv I7 ( .in(net1), .out(net3) );
  inv I2 ( .in(net2), .out(net4) );
  inv I16 ( .in(net4), .out(net3) );
  inv I15 ( .in(net3), .out(net4) );
  inv I13 ( .in(net1), .out(net2) );
  inv I1 ( .in(net10), .out(net2) );
  inv I6 ( .in(IN), .out(net10) );
  inv I18 ( .in(net6), .out(net5) );
  inv I17 ( .in(net5), .out(net6) );
endmodule


