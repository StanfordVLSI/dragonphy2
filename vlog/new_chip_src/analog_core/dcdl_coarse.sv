
module dcdl_coarse #(
parameter Nbit = 5
)(
input in, 
input [2**Nbit-2:0] thm, 
output out 
);
	
  wire   dr0, dm0;
  wire   [2**Nbit-2:0] dm;
  wire   [2**Nbit-3:0] dr;
  wire   [2**Nbit-2:0] df;
  wire   [2**Nbit-2:0] thm_b;

  n_and in_and_in_dont_touch ( .in1(thm_b[0]), .in2(in), .out(dm0) );
  n_and in_and_out_dont_touch ( .in1(dr0), .in2(dm0), .out(out) );
  
  n_and in_and_chain_1_dont_touch[2**Nbit-2:0] ( .in1(thm), .in2({df[2**Nbit-3:0],in}), .out(df) );
  n_and in_and_chain_2_dont_touch[2**Nbit-2:0] ( .in1({1'b1,thm_b[2**Nbit-2:1]}), .in2(df), .out(dm) );
  n_and in_and_chain_3_dont_touch[2**Nbit-2:0] ( .in1({1'b1,dr}), .in2(dm), .out({dr,dr0}) );
    
endmodule

