
 module input_divider (
 input in,
 input in_mdll,
 input sel_clk_source,
 input en,
 input en_meas,
 input [2:0] ndiv,
 input bypass_div,
 input bypass_div2,
 output out,
 output out_meas
 );

reg div2;
reg div_out;
reg [2:0] count;

assign mux_insel_out = sel_clk_source ? in_mdll : in;
assign mux1_out = bypass_div2 ? mux_insel_out : div2;
assign out = bypass_div ? mux1_out : div_out;
assign out_meas = (en_meas&out);

always @(posedge mux_insel_out or negedge en) begin
	if (!en) div2 <= 0;
	else div2 <= ~div2; 
end

always @(posedge mux1_out or negedge en) begin
	if (!en) begin 
		div_out <= 0;
		count <= 0;
	end
	else begin
		if (count == 2**(ndiv)-1) begin
			div_out <= ~div_out;
			count <= 0;
		end
		else count <= count+1;
	end	
end

endmodule

