
 module snh ( clk, clkb, in_p, in_n, out_p, out_n );

 output  [3:0] out_p;
 output  [3:0] out_n;

 input  in_p;
 input  in_n;
 input  [3:0] clk;
 input  [3:0] clkb;

 SW  ISWp0 (.IN(in_p), .CLK(clk[0]), .CLKB(clkb[0]), .OUT(out_p[0]));
 SW  ISWn0 (.IN(in_n), .CLK(clk[0]), .CLKB(clkb[0]), .OUT(out_n[0]));

 SW  ISWp1 (.IN(in_p), .CLK(clk[1]), .CLKB(clkb[1]), .OUT(out_p[1]));
 SW  ISWn1 (.IN(in_n), .CLK(clk[1]), .CLKB(clkb[1]), .OUT(out_n[1]));

 SW  ISWp2 (.IN(in_p), .CLK(clk[2]), .CLKB(clkb[2]), .OUT(out_p[2]));
 SW  ISWn2 (.IN(in_n), .CLK(clk[2]), .CLKB(clkb[2]), .OUT(out_n[2]));
 
 SW  ISWp3 (.IN(in_p), .CLK(clk[3]), .CLKB(clkb[3]), .OUT(out_p[3]));
 SW  ISWn3 (.IN(in_n), .CLK(clk[3]), .CLKB(clkb[3]), .OUT(out_n[3]));
 
endmodule

