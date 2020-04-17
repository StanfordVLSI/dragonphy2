
module ff_e_c_rn (input D, input E, input CP, input CDN, output reg Q);


always @(posedge CP or negedge CDN ) 
	if(!CDN) Q <= 0;
	else Q <= E ? D : Q;

endmodule


