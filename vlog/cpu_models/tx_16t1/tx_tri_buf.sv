module tx_tri_buf(
    input wire logic DIN,
    input wire logic en,
    output logic DOUT 
);
always @ (en) begin
	if (en) begin
		DOUT = DIN;
	end	else if (!en) begin
		DOUT = DOUT;
	end
end	

endmodule