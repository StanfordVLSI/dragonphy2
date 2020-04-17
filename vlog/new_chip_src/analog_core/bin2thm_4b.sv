
module bin2thm_4b #(
parameter Nbit = 4
) 
(
input [Nbit-1:0] bin,
output reg [2**Nbit-2:0] thm
);


always_comb
 thm= ~('1 << bin);

endmodule
