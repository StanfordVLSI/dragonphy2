/********************************************************************
filename: ti_adc_retimer.sv

Description: 
Deserialize 16 adc slices' outputs (data+sign)

Assumptions:

Todo:
    - Can reduce clock latency from 2 cycle to 1 cycle.
    - Depending on timing check results, one might need to change
      left_edge and right_edge params.

********************************************************************/

`default_nettype none
module ti_adc_retimer_v2 import const_pack::*; (
    input wire logic clk_retimer,                    // clock for serial to parallel retiming
    input wire logic [Nadc-1:0] in_data [Nti-1:0],   // serial data
    input wire logic [Nti -1:0] in_sign,             // sign of serial data

    input wire logic [Nadc-1:0] in_data_rep [1:0],
    input wire logic [1:0]      in_sign_rep,

    input wire logic [Nti-1:0] mux_ctrl_1,
    input wire logic [Nti-1:0] mux_ctrl_2,


    output logic [Nadc-1:0] out_data [Nti-1:0], // parallel data
    output logic [Nti-1:0]  out_sign, // parallel data
    output logic [Nadc-1:0] out_data_rep [1:0], // parallel data
    output logic [1:0]      out_sign_rep // parallel data
);

// wires, regs
wire [Nadc-1:0] do_reorder[Nti-1:0];
wire [Nti-1:0]  do_reorder_sign;

logic [Nadc-1:0] mux_out_1 [Nti-1:0];
logic [Nadc-1:0] mux_out_2 [Nti-1:0];

reg  [Nadc-1:0] pos_latch      [Nti-1:0];
reg  [Nadc-1:0] pos_flop_1     [Nti-1:0];
reg  [Nadc-1:0] pos_flop_2     [Nti-1:0];

logic mux_out_1_sign [Nti-1:0]; 
logic mux_out_2_sign [Nti-1:0];

reg [Nadc-1:0] pos_latch_sign [Nti-1:0];
reg  pos_flop_1_sign [Nti-1:0];
reg  pos_flop_2_sign [Nti-1:0];


genvar k;

generate
    // Replicas both run off the same clock - the direct output of the input clock buffer
    // We need to characterize the delay between the two and account for it here
    for (k = 0; k<2; k++) begin: genblk_rep
        always @(posedge clk_retimer) begin
            out_data_rep[k] <= in_data_rep[k];
            out_sign_rep[k] <= in_sign_rep[k];
        end
    end

    for (k=0;k<Nti;k++) begin: genblk1
        //Reorder the slices
        assign do_reorder[k]      = in_data[(k%4)*4+(k>>2)];
        assign do_reorder_sign[k] = in_sign[(k%4)*4+(k>>2)];

        // Negative Edge Latch
        // Pos Edge Latch
        always_latch begin
            if(clk_retimer) begin
                pos_latch[k]      <= do_reorder[k];
                pos_latch_sign[k] <= do_reorder_sign[k];
            end
        end

        //Mux 1 and Mux 2
        always_comb begin
            mux_out_1[k]      = mux_ctrl_1[k] ? do_reorder[k]      : pos_latch[k];
            mux_out_1_sign[k] = mux_ctrl_1[k] ? do_reorder_sign[k] : pos_latch_sign[k];

            mux_out_2[k]      = mux_ctrl_2[k] ? pos_flop_1[k]      : pos_flop_2[k];
            mux_out_2_sign[k] = mux_ctrl_2[k] ? pos_flop_1_sign[k] : pos_flop_2_sign[k];

            out_data[k]       = mux_out_2[k];
            out_sign[k]       = mux_out_2_sign[k];
        end
        // Both flops
        always_ff @(posedge clk_retimer) begin
            pos_flop_1[k]      <= mux_out_1[k];
            pos_flop_1_sign[k] <= mux_out_1_sign[k];
            pos_flop_2[k]      <= pos_flop_1[k];
            pos_flop_2_sign[k] <= pos_flop_1_sign[k];
        end
    end
endgenerate

///////////////////////////////
// Verification purpose only 
///////////////////////////////

/*****************
// synopsys translate_off

    initial begin
        assert (rght_edge > 7) else $error("Right Edge of Retimer occurs before negedge of SCLK");
        assert (left_edge < 7) else $error("Left Edge of Retimer occurs after negedge of SCLK");
    end
    
    
    // parallel to serial conversion to extract bitstream at full rate 
    // then compare the rx bitstream (tx_dout) with the tx bitstream at the testbench level
    reg hs_clk;
    reg clk_retimer_d;
    reg [Nti-1:0] hs_data;
    wire [Nti-1:0] rx_data;
    wire rx_dout;

    initial begin
        hs_clk = 1'b0;
        forever begin
            #(62.5ps) hs_clk = ~hs_clk;
        end
    end
    always @(hs_clk) clk_retimer_d <= clk_retimer; 
    always @(hs_clk)
        if ({clk_retimer_d, clk_retimer}==2'b01) hs_data <= rx_data;
        else hs_data <= hs_data >> 1;
    assign rx_dout = hs_data[0];
    
    generate
        for (k=0;k<Nti;k++) begin: rxdatagen
            assign rx_data[k] = (out_data[k][Nadc-1]==1'b0);
        end
    endgenerate

// synopsys translate_on
*****************/

endmodule
`default_nettype wire
