`timescale 100ps/1ps  // Remove this line before synthesis

module mux (input in0, input in1, input sel, output out);
// #0.2; // Remove this line before synthesis, Tcp delay ~ 2FO4
 assign  out = sel ? in1:in0;
endmodule


