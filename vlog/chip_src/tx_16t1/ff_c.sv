`timescale 100ps/1ps  // Remove this line before synthesis

module ff_c (
    input D,    
    input CP,
    output reg Q
);
    always @(posedge CP) begin
        #0.2; // #0.3 is added to account for Tcq delay of DFF, remove #0.3 line before synthesis
        Q <= D;
    end
endmodule


