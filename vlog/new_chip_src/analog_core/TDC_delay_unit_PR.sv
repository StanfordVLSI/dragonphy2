
module TDC_delay_unit_PR (input inv_in, input ff_in, input clk_phase_reverse, input pstb, output inv_out, output reg ff_out, output xnor_out);
reg phase_reverse;
assign inv_out = ~inv_in;
assign xnor_out = ~(inv_out^phase_reverse);

always @(posedge clk_phase_reverse or negedge pstb) begin
 if(!pstb) phase_reverse <= 1'b1;
 else phase_reverse <= ff_out;
end
always @(posedge xnor_out) ff_out <= ff_in;
endmodule


