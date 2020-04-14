
module sync_divider ( out, in, ndiv, rstb );
  input [2:0] ndiv;
  input in, rstb;
  output out;
  wire   net037, net036, net035, rst, net034, net048, hi, lo, net060, net055,
         net057, net056, net054, net064, net072, net071;
  wire   [0:4] ndiv_thm;
  wire   [0:2] q;
  wire   [0:5] qb;
  wire   [0:3] an;

  inv I10 ( .in(net037), .out(ndiv_thm[3]) );
  inv I1 ( .in(ndiv[1]), .out(net036) );
  inv I0 ( .in(ndiv[2]), .out(net037) );
  inv I2 ( .in(ndiv[0]), .out(net035) );
  inv I91 ( .in(q[0]), .out(qb[0]) );
  inv I134 ( .in(rstb), .out(rst) );
  inv I110 ( .in(net034), .out(qb[3]) );
  inv I104 ( .in(q[1]), .out(qb[1]) );
  inv I107 ( .in(q[2]), .out(qb[2]) );
  inv I137 ( .in(net048), .out(qb[4]) );
  inv I115 ( .in(out), .out(qb[5]) );
  inv I139 ( .in(hi), .out(lo) );
  tieh I128 ( .Z(hi) );
  ff_e_c_rn I90 ( .D(qb[0]), .E(hi), .CP(in), .CDN(net060), .Q(q[0]) );
  ff_e_c_rn I111 ( .D(qb[3]), .E(an[1]), .CP(in), .CDN(net055), .Q(net034) );
  ff_e_c_rn I105 ( .D(qb[1]), .E(qb[0]), .CP(in), .CDN(net057), .Q(q[1]) );
  ff_e_c_rn I108 ( .D(qb[2]), .E(an[0]), .CP(in), .CDN(net056), .Q(q[2]) );
  ff_e_c_rn I114 ( .D(qb[5]), .E(an[3]), .CP(in), .CDN(net054), .Q(out) );
  ff_e_c_rn I136 ( .D(qb[4]), .E(an[2]), .CP(in), .CDN(net064), .Q(net048) );
  a_nd I112 ( .in1(an[1]), .in2(qb[3]), .Z(an[2]) );
  a_nd I109 ( .in1(an[0]), .in2(qb[2]), .Z(an[1]) );
  a_nd I106 ( .in1(qb[0]), .in2(qb[1]), .Z(an[0]) );
  a_nd I138 ( .in1(an[2]), .in2(qb[4]), .Z(an[3]) );
  n_or I6 ( .in1(net037), .in2(net072), .out(ndiv_thm[4]) );
  n_or I122 ( .in1(ndiv_thm[1]), .in2(rst), .out(net057) );
  n_or I121 ( .in1(ndiv_thm[0]), .in2(rst), .out(net060) );
  n_or I135 ( .in1(ndiv_thm[4]), .in2(rst), .out(net064) );
  n_or I123 ( .in1(ndiv_thm[2]), .in2(rst), .out(net056) );
  n_or I124 ( .in1(ndiv_thm[3]), .in2(rst), .out(net055) );
  n_or I125 ( .in1(lo), .in2(rst), .out(net054) );
  a_nd I8 ( .in1(net036), .in2(net035), .Z(net072) );
  o_r I7 ( .in1(net036), .in2(net035), .Z(net071) );
  n_and I4 ( .in1(net037), .in2(net036), .out(ndiv_thm[1]) );
  n_and I9 ( .in1(net037), .in2(net071), .out(ndiv_thm[2]) );
  n_and3 I3 ( .in1(net037), .in2(net036), .in3(net035), .out(ndiv_thm[0])
         );
endmodule

