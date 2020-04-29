
module mux16 ( out, in, sel );
  input [15:0] in;
  input [3:0] sel;
  output out;
  wire  [3:0] mid;

  mux4_fixed imux4_1_dont_touch ( .in(in[3:0]), .sel(sel[1:0]), .out(mid[0]) );
  mux4_fixed imux4_2_dont_touch ( .in(in[7:4]), .sel(sel[1:0]), .out(mid[1]) );
  mux4_fixed imux4_3_dont_touch ( .in(in[11:8]), .sel(sel[1:0]), .out(mid[2]) );
  mux4_fixed imux4_4_dont_touch ( .in(in[15:12]), .sel(sel[1:0]), .out(mid[3]) );
  mux4_fixed imux4_5_dont_touch ( .in(mid), .sel(sel[3:2]), .out(out) );
 
endmodule


