module adv_prbs21 #(
    parameter logic [20:0] init = '1
)(
  input clk,  // clock
  input rst,  // reset (act. high)
  output out  // output stream
);

timeunit `DAVE_TIMEUNIT ;
timeprecision `DAVE_TIMEUNIT ;

reg [20:0] sr= init;

always @(posedge clk or posedge rst) begin
  if(rst) sr = init;
  else begin
    sr[20:1] <= sr[19:0];
    sr[0] <= sr[20] ^ sr[1];
  end
end

assign out = sr[6];

endmodule