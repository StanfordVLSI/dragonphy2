module phase_monitor_sub(
	input wire logic ph_ref,
	input wire logic ph_in,
	input wire logic en_sync,
	input wire logic clk_async,
	input wire logic [1:0] sel_sign,
	output reg ff_in,
	output reg ff_ref,
	output wire logic xor_ref_bf
);

wire net_x;
wire xor_in;
wire xor_ref;

assign xor_in = ph_in ^ sel_sign[0];
assign xor_ref = ph_ref ^ sel_sign[1];
assign net_x = xor_in;
assign xor_ref_bf = xor_ref;

always @(posedge xor_in, negedge en_sync)
  if (!en_sync) ff_in <= 1'b0;
  else ff_in <= clk_async;

always @(posedge xor_ref, negedge en_sync)
  if (!en_sync) ff_ref <= 1'b0;
  else ff_ref <= clk_async;

endmodule