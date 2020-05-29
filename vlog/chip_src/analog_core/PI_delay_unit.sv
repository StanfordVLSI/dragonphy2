module PI_delay_unit ( arb_out, buf_out, chain_out, arb_in, chain_in, inc_del, en_arb, en_mixer );
 
input  arb_in, chain_in, inc_del, en_arb, en_mixer;
output buf_out, chain_out;
output reg arb_out;

del_PI idel_PI (.in(chain_in), .out(chain_out));

assign in0_gated = chain_out & en_arb;
assign in1_gated = arb_in & en_arb;

always @(posedge in1_gated or negedge en_arb) begin
  if(!en_arb) arb_out <=0;
  else arb_out <= in0_gated;
end 

phase_blender_1b  iblender_1b ( .ph_in({arb_in, chain_out}), .ph_out(mixer_out), .en_mixer(en_mixer));
inc_delay iinc_delay (.in(mixer_out), .out(buf_out), .inc_del(inc_del));

endmodule

