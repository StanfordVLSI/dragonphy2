
module phase_blender_1b (input [1:0] ph_in, input en_mixer, output ph_out);

mux IMUX0 (.I0(ph_in[0]), .I1(ph_in[1]), .Z(ph_out), .S(en_mixer));
mux IMUX1 (.I0(ph_in[0]), .I1(1'b0), .Z(ph_out), .S(1'b0));

endmodule


