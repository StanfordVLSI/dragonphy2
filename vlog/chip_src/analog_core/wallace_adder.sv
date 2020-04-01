module wallace_adder #()
(
input [254:0] d_in,
input sign_in,
input clk,
output reg [7:0] d_out,
output reg sign_out
);

logic [7:0] sum;
reg sign_in_sampled;
reg [254:0] d_in_sampled;

always @(posedge clk) begin
	d_in_sampled <= d_in;
	sign_in_sampled <=sign_in;
  	sum=0;	
	for (int i=0;i<255;i++) sum = sum+d_in_sampled[i];
	d_out <= sum;
        sign_out <= sign_in_sampled;
end

endmodule

