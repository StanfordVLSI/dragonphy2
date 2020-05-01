
module phase_monitor_sub(
    input ph_ref,
    input ph_in,
    input en_sync,
    input clk_async,
    input [1:0] sel_sign,
    output reg ff_in,
    output reg ff_ref,
    output xor_ref_bf
);

assign xor_in = ph_in^sel_sign[0];
assign xor_ref = ph_ref^sel_sign[1];
assign xor_ref_bf = xor_ref;

always @(posedge xor_in or negedge en_sync) begin
	if(!en_sync) ff_in <= 0;
	else ff_in <= clk_async;
end

always @(posedge xor_ref or negedge en_sync) begin
	if(!en_sync) ff_ref <= 0;
	else ff_ref <= clk_async;
end

endmodule





