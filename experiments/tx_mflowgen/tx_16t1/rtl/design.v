`default_nettype none

module tx_inv (
    input wire logic DIN,
    output wire logic DOUT 
);
    INV_X4 inv_4_fixed (
        .A(DIN),
        .ZN(DOUT)
    );
endmodule

module mux (
    input wire logic in0,
    input wire logic in1,
    input wire logic sel,
    output wire logic out
);
    assign out = sel ? in1 : in0;
endmodule

module ff_c (
    input wire logic D,
    input wire logic CP,
    output reg Q
);
    always @(posedge CP) begin
        Q <= D;
    end
endmodule

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

module div_b2 (
    input wire logic clkin,
    input wire logic rst,
    output wire logic clkout
);
    ff_c_rn ff_i (
        .D(~clkout),
        .CP(clkin),
        .CDN(~rst),
        .Q(clkout)
    );
endmodule

module dlatch_n (
    input wire logic clk,
    input wire logic din,
    output reg dout
);
    always @ (clk or din) begin
        if (!clk) begin
            dout <= din;
        end
    end
endmodule

module hr_2t1_mux_top (
    input wire logic clk_b,
    input wire logic [1:0] din,
    output wire logic dout
);
    logic D0L, D1M, L0M;
    ff_c dff_0 (.D(din[0]), .CP(clk_b), .Q(D0L));
    ff_c dff_1 (.D(din[1]), .CP(clk_b), .Q(D1M));
    dlatch_n latch_0 (.clk(clk_b), .din(D0L), .dout(L0M));
    mux mux_0 (.in0(L0M), .in1(D1M), .sel(clk_b), .out(dout));
endmodule

module hr_4t1_mux_top (
    input wire logic clk_b,     // Half rate clock input
    input wire logic [3:0] din,  // Two-bit input data
    output wire logic dout,
    input wire logic clk_half  // Divide clock, same as the prbs generator clock
);
    logic [1:0] hd;
    
    hr_2t1_mux_top hr_2t1_mux_0 (
        .clk_b(clk_half),
        .din(din[1:0]),
        .dout(hd[0])
    );
    
    hr_2t1_mux_top hr_2t1_mux_1 (
        .clk_b(clk_half),
        .din(din[3:2]),
        .dout(hd[1])
    );
    
    hr_2t1_mux_top hr_2t1_mux_2 (
        .clk_b(clk_b),
        .din(hd),
        .dout(dout)
    );
endmodule

module hr_16t4_mux_top (
    input wire logic clk_hr,
    input wire logic clk_prbs,
    input wire logic [15:0] din,
    input wire logic rst,
    output wire logic [3:0] dout
);
    genvar i;
    generate
        for (i=1; i<5; i=i+1) begin : iMUX
            hr_4t1_mux_top mux_4t1 (
                .clk_b(clk_hr),
                .din(din[4*i-1:4*(i-1)]),
                .dout(dout[i-1]),
                .clk_half(clk_prbs)
            );
        end
    endgenerate
endmodule

module qr_4t1_mux_top (
    input wire logic clk_Q,
    input wire logic clk_QB,
    input wire logic clk_I,
    input wire logic clk_IB,
    input wire logic [3:0] din,
    input wire logic rst,
    output wire logic data
);

logic D0DQ;
ff_c dff_Q0 (.D(din[3]), .CP(clk_Q), .Q(D0DQ));

logic D0DI;
ff_c dff_I0 (.D(din[2]), .CP(clk_I), .Q(D0DI));

logic D0DQB, D1DQB;
ff_c dff_QB0 (.D(din[1]), .CP(clk_Q), .Q(D0DQB));
ff_c dff_QB1 (.D(D0DQB), .CP(clk_QB), .Q(D1DQB));

logic D0DIB, D1DIB;
ff_c dff_IB0 (.D(din[0]), .CP(clk_I), .Q(D0DIB));
ff_c dff_IB1 (.D(D0DIB), .CP(clk_IB), .Q(D1DIB));

logic mux_out;
qr_mux_fixed mux_4 (
    .DIN0(D0DI),
    .DIN1(D1DQB),
    .DIN2(D0DQ),
    .DIN3(D1DIB),
    .E0(clk_Q),
    .E1(clk_I),
    .DOUT(mux_out)
);

genvar i;
generate
    for (i=0; i<4; i=i+1) begin : i_INVBUF 
        tx_inv inv_buf (
            .DIN(mux_out),
            .DOUT(data)
        );
    end
endgenerate

endmodule
    
module tx_top (
    input wire logic [15:0] din,
    input wire logic [3:0] clk_interp_slice
    input wire logic rst, 
    output wire logic clk_prbsgen,
    output wire logic dout_p,
    output wire logic dout_n
);

// Instantiate half-rate 16 to 4 mux top
logic [3:0] qr_data_p;  // Output of 16 to 4 mux, positive
logic [3:0] qr_data_n;  // Output of 16 to 4 mux, negative
logic clk_halfrate;  // Input clock for 16 to 4 mux

// Global reset 
logic rstb;
assign rstb = ~rst;

// clk_interp_slice[0] -> clk_Q
// clk_interp_slice[1] -> clk_I
// clk_interp_slice[2] -> clk_QB
// clk_interp_slice[3] -> clk_IB

// Data + positive
hr_16t4_mux_top hr_mux_16t4_0 (
    .clk_hr(clk_halfrate),
    .clk_prbs(clk_prbsgen),
    .din(din),
    .rst(rst), 
    .dout(qr_data_p)
);

//Instantiate quarter-rate 4 to 1 mux top
qr_4t1_mux_top qr_mux_4t1_0 (
    .clk_Q(clk_interp_slice[0]),
    .clk_QB(clk_interp_slice[2]),
    .clk_I(clk_interp_slice[1]),
    .clk_IB(clk_interp_slice[3]),
    .din(qr_data_p),
    .rst(rst),
    .data(dout_p)
);

// Data - negative
hr_16t4_mux_top hr_mux_16t4_1 (
    .clk_hr(clk_halfrate),
    .clk_prbs(clk_prbsgen),
    .din(~din),
    .rst(rst),
    .dout(qr_data_n)
);

//Instantiate quarter-rate 4 to 1 mux top
qr_4t1_mux_top qr_mux_4t1_1 (
    .clk_Q(clk_interp_slice[0]),
    .clk_QB(clk_interp_slice[2]),
    .clk_I(clk_interp_slice[1]),
    .clk_IB(clk_interp_slice[3]),
    .din(qr_data_n),
    .rst(rst),
    .data(dout_n)
);

// clock dividers
div_b2 div0 (.clkin(clk_interp_slice[2]), .rst(rst), .clkout(clk_halfrate));
div_b2 div1 (.clkin(clk_halfrate), .rst(rst), .clkout(clk_prbsgen));

endmodule

`default_nettype wire
