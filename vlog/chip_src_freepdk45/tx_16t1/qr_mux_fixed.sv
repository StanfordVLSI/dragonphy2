// FreePDK45 does not appear to have a dedicated
// MUX4 cell, so the implementation used here
// is simply synthesizable RTL

`default_nettype none

module qr_mux_fixed (
    input wire logic DIN0,
    input wire logic DIN1,
    input wire logic DIN2,
    input wire logic DIN3,
    input wire logic E0,
    input wire logic E1,
    output wire logic DOUT 
);

    always_comb begin
        case ({E1, E0}) 
            2'b00 : DOUT = ~DIN0;
            2'b01 : DOUT = ~DIN1;
            2'b10 : DOUT = ~DIN2;
            2'b11 : DOUT = ~DIN3;
        endcase
    end

endmodule

`default_nettype wire
