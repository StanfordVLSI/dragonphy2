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
module ti_adc_retimer import const_pack::*; #(
    parameter integer left_edge=4,
    parameter integer rght_edge=12
)(
    input wire logic clk_retimer,   // clock for serial to parallel retiming
    input wire logic [Nadc-1:0] in_data [Nti-1:0],   // serial data
    input wire logic [Nti-1:0] in_sign,                     // sign of serial data

    input wire logic [Nadc-1:0] in_data_rep [1:0],
    input wire logic [1:0] in_sign_rep,

    output reg [Nadc-1:0] out_data [Nti-1:0], // parallel data
    output reg [Nti-1:0] out_sign, // parallel data
    output reg [Nadc-1:0] out_data_rep [1:0], // parallel data
    output reg [1:0] out_sign_rep // parallel data
);

// wires, regs

wire [Nadc-1:0] do_reorder[Nti-1:0];
wire [Nti-1:0] do_reorder_sign;
reg  [Nadc-1:0] data_stage1 [Nti-1:0];
reg  [Nadc-1:0] data_stage2 [Nti-1:0];
reg  [Nti-1:0] sign_stage1;
reg  [Nti-1:0] sign_stage2;

reg [Nadc-1:0] data_stage2_rep [1:0];
reg [1:0]      sign_stage2_rep;

genvar k;

generate
    // reorder slice outputs to bit stream sequences
    for (k=0;k<Nti;k++) begin: genblk1
        assign do_reorder[k] = in_data[(k%4)*4+(k>>2)];
        assign do_reorder_sign[k] = in_sign[(k%4)*4+(k>>2)];
    end
    // Replicas both run off the same clock - the direct output of the input clock buffer
    // We need to characterize the delay between the two and account for it here
    for (k = 0; k<2; k++) begin: genblk_rep
        always @(posedge clk_retimer) begin
            data_stage2_rep[k] <= in_data_rep[k];
            sign_stage2_rep[k] <= in_sign_rep[k];
        end
    end

    // 
    for (k=left_edge; k<rght_edge; k++) begin :genblk2
        always @(posedge clk_retimer) begin
            data_stage2[k] <= do_reorder[k];
            sign_stage2[k] <= do_reorder_sign[k];
        end
    end
  
    for (k = 0; k < left_edge; k++) begin :genblk3
        always @(negedge clk_retimer) begin
            data_stage1[k] <= do_reorder[k];
            sign_stage1[k] <= do_reorder_sign[k];
        end
        always @(posedge clk_retimer) begin
            data_stage2[k] <= data_stage1[k];
            sign_stage2[k] <= sign_stage1[k];
        end
    end
  
    for (k=rght_edge; k<Nti; k++) begin : genblk4
        always @(negedge clk_retimer) begin 
            data_stage2[k] <= do_reorder[k];
            sign_stage2[k] <= do_reorder_sign[k];
        end
    end
endgenerate

// last stage
always @(posedge clk_retimer) begin
    out_data <= data_stage2;
    out_sign <= sign_stage2;
    out_data_rep <= data_stage2_rep;
    out_sign_rep <= sign_stage2_rep;
end


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