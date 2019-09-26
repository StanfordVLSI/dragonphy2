// modified from: https://github.com/StanfordVLSI/DaVE/blob/master/mLingua/samples/misc/prbs21.v

module prbs21 (
    input wire logic clk_i,
    output wire logic out_o
);

    reg [20:0] sr;
    
    always @(posedge clk_i or posedge `EMU_RST) begin
        if (`EMU_RST == 1'b1) begin
            sr <= '1;
        end else begin
            sr <= {sr[19:0], sr[20] ^ sr[1]};
        end
    end
    
    assign out_o = sr[6];

endmodule
