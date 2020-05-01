
module bin2thm_5b #(
parameter Nbit = 5
) 
(
input [Nbit-1:0] bin,
output reg [2**Nbit-2:0] thm
);


always_comb
 thm= ~('1 << bin);

endmodule
