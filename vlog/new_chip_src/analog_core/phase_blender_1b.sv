
module phase_blender_1b (input [1:0] ph_in, input en_mixer, output ph_out);

mux IMUX0 (.in0(ph_in[0]), .in1(ph_in[1]), .out(ph_out), .sel(en_mixer));
mux IMUX1 (.in0(ph_in[0]), .in1(1'b0), .out(ph_out), .sel(1'b0));

endmodule


