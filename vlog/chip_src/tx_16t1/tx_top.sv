`timescale 100ps/1ps   //  unit_time / time precision

module tx_top (
    input wire [15:0] din,
    input wire clk_q,  // The clock inout must follow this order, (rising edge order) Q->I->QB->IB-Q
    input wire clk_i,  // The clock is a quarter-rate clock with respect to output data rate
    input wire clk_qb, // q, i, qb, ib spaced evenly within a clock cycle
    input wire clk_ib,
    output reg clk_prbsgen,  // Output clock for 16-bit prbs generator
    output reg dout // Data output
    );

//This Tx top specify the connect between qr_4t1_mux_top and hr_16t4_mux_top

//Instantiate half-rate 16 to 4 mux top
wire [3:0] qr_data;  // Output of 16 to 4 mux
wire clk_halfrate;  // Input clock for 16 to 4 mux

hr_16t4_mux_top hr_mux_16t4 (
    .clk_hr(clk_halfrate), // This is a divided (by 2) clock from quarter-rate 4 to 1 mux
    .din(din), 
    .dout(qr_data),
    .clk_b2(clk_prbsgen)  // This clk_halfrate 
);

//Instantiate quarter-rate 4 to 1 mux top

qr_4t1_mux_top qr_mux_4t1 (
    .clk_Q(clk_q),  // Quarter-rate clock input
    .clk_QB(clk_qb),
    .clk_I(clk_i),
    .clk_IB(clk_ib),
    .din(qr_data), // Quarter-rate data from half-rate 16 to 4 mux
    .ck_b2(clk_halfrate), // Divided quarter-rate clock for 16 to 4 mux
    .data(dout) // Final data output
);

endmodule


