`timescale 1fs/1fs   //  unit_time / time precision

`default_nettype none

module tx_top import const_pack::*; #(
) (
    input wire logic [15:0] din,
    input wire logic mdll_clk, // Clock from MDLL
    input wire logic ext_clk, // Clock from external source

    input wire logic rst, // Global reset for Tx
    input wire logic [Npi-1:0] ctl_pi [Nout-1:0],
    input wire logic clk_async,
    input wire logic clk_encoder,
    input wire logic ctl_valid,

    output wire logic clk_prbsgen,  // Output clock for 16-bit prbs generator
    output wire logic dout_p, // Data output
    output wire logic dout_n,
    tx_debug_intf.tx tx
);

//This Tx top specify the connect between qr_4t1_mux_top and hr_16t4_mux_top

// Instantiate half-rate 16 to 4 mux top
wire [3:0] qr_data_p;  // Output of 16 to 4 mux, positive
wire [3:0] qr_data_n;  // Output of 16 to 4 mux, negative
wire clk_halfrate;  // Input clock for 16 to 4 mux
wire logic clk_halfrate_n;

wire [3:0] clk_interp_slice; // Output from the phase interpolator
wire [3:0] clk_interp_sw; //

wire clk_in_pi;
wire logic mtb_n;  // mux to buffer -
wire logic mtb_p;  // mux to buffer +


wire [15:0] din_reorder;
assign din_reorder[0] = din[15];
assign din_reorder[4] = din[14];
assign din_reorder[8] = din[13];
assign din_reorder[12] = din[12];
assign din_reorder[2] = din[11];
assign din_reorder[6] = din[10];
assign din_reorder[10] = din[9];
assign din_reorder[14] = din[8];
assign din_reorder[1] = din[7];
assign din_reorder[5] = din[6];
assign din_reorder[9] = din[5];
assign din_reorder[13] = din[4];
assign din_reorder[3] = din[3];
assign din_reorder[7] = din[2];
assign din_reorder[11] = din[1];
assign din_reorder[15] = din[0];

// Input order [0][1][2][3][4][5][6][7][8][9][10][11][12][13][14][15]
//                           After going through the TX                     
// Output order [0][4][8][12][2][6][10][14][1][5][9][13][3][7][11][15]
//             Late   <--------------------------------------->   Early




// Global reset 
wire rstb;
assign rstb = ~rst;

    // Instantiate the phase interpolator
    logic [3:0] inv_del_out_pi;
    logic [Nunit_pi-1:0] en_unit_pi [Nout-1:0]; 
    // Q I QB IB clock
    // 4ch. PI
    generate 
        for (genvar k=0; k<4; k=k+1) begin: iPI
            phase_interpolator iPI(
                 //inputs
                 // portion 1 checked | Yes
                .rstb(rstb),
                .clk_in(clk_in_pi), // From input divider
                .clk_async(clk_async),
                .clk_encoder(clk_encoder),  
                .ctl(ctl_pi[k]),
                .ctl_valid(ctl_valid),
                // portion 2 checked | Yes
                .en_gf(1'b0), // 
                .en_arb(4'hf), // 
                .en_delay(4'hf), //
                .en_ext_Qperi(4'h0),
                .en_pm(4'h0),
                .en_cal(4'h0),

                .en_unit(32'hffffffff), // en_unit_pi added

                .ext_Qperi(5'b10001),
                .sel_pm_sign(2'b00),
                .inc_del(32'h0),
                .ctl_dcdl_slice(2'b00),
                .ctl_dcdl_sw(2'b00),
                .ctl_dcdl_clk_encoder(2'b00),
                .disable_state(4'h0),
                .en_clk_sw(4'hf),
                // portion 3 checked | Yes
                //outputs
                .clk_out_slice(clk_interp_slice[k])
//                .clk_out_sw(clk_interp_sw[k])
//                .Qperi(tx.Qperi[k]),
//                .cal_out(tx.cal_out_pi[k]),
//                .del_out(inv_del_out_pi[k]),
//                .pm_out(tx.pm_out_pi[k]),
//                .max_sel_mux(tx.max_sel_mux[k]),
//                .cal_out_dmm()
            );
            // portion 4 checked | Yes
//            assign tx.pi_out_meas[k] = (tx.sel_meas_pi[k] ? clk_interp_slice[k] : clk_interp_sw[k]) & tx.en_meas_pi[k];
//            assign en_unit_pi[k] = ~tx.enb_unit_pi[k];  
        end
    endgenerate

// Clock input divider
	input_divider indiv (
	    // inputs 
        //Portion 1 checked?
		.in(ext_clk),
		.in_mdll(mdll_clk),
		.sel_clk_source(tx.sel_clk_source),
		.en(tx.en_inbuf),
		.bypass_div(tx.bypass_inbuf_div),
		.bypass_div2(tx.bypass_inbuf_div2),
		.ndiv(tx.inbuf_ndiv),
		.en_meas(tx.en_inbuf_meas),
	    // outputs
		.out(clk_in_pi),  // To phase interpolator /internal connection
		.out_meas(tx.inbuf_out_meas)
	);

// output drivers
    wire del_out;
    assign del_out = tx.sel_del_out_pi ? inv_del_out_pi[0] : clk_in_pi ;
    assign tx.del_out_pi = del_out & tx.en_del_out_pi;

//Let's define the order of the four hases interpolator output 
//      tx.clk_interp_slice[0] -> clk_Q
//      tx.clk_interp_slice[1] -> clk_I
//      tx.clk_interp_slice[2] -> clk_QB
//      tx.clk_interp_slice[3] -> clk_IB
//////////////////////////////////////////////////////////////

// Data + positive
hr_16t4_mux_top hr_mux_16t4_0 (
    .clk_hr(clk_halfrate), // This is a divided (by 2) clock from quarter-rate 4 to 1 mux
    .clk_prbs(clk_prbsgen),
    .din(din_reorder),
    .rst(rst), 
    .dout(qr_data_p)
);

//Instantiate quarter-rate 4 to 1 mux top
qr_4t1_mux_top qr_mux_4t1_0 (
    .clk_Q(clk_interp_slice[0]),  // Quarter-rate clock input
    .clk_QB(clk_interp_slice[2]),
    .clk_I(clk_interp_slice[1]),
    .clk_IB(clk_interp_slice[3]),
    .din(qr_data_p), // Quarter-rate data from half-rate 16 to 4 mux
    .rst(rst),
    .data(mtb_p) // Final data output + positive Output driver and termination needs to be added 
);

// Data - negative
hr_16t4_mux_top hr_mux_16t4_1 (
    .clk_hr(clk_halfrate), // This is a divided (by 2) clock from quarter-rate 4 to 1 mux
    .clk_prbs(clk_prbsgen),
    .din(~din_reorder), // Inverting the data input for differential output
    .rst(rst),
    .dout(qr_data_n)
);

//Instantiate quarter-rate 4 to 1 mux top
qr_4t1_mux_top qr_mux_4t1_1 (
    .clk_Q(clk_interp_slice[0]),  // Quarter-rate clock input
    .clk_QB(clk_interp_slice[2]),
    .clk_I(clk_interp_slice[1]),
    .clk_IB(clk_interp_slice[3]),
    .din(qr_data_n), // Quarter-rate data from half-rate 16 to 4 mux
    .rst(rst),
    .data(mtb_n) // Final data output - negative Output driver and termination needs to be added
);

div_b2 div0 (.clkin(clk_interp_slice[2]), .rst(rst), .clkout(clk_halfrate));  // 4GHz to 2GHz, output goes to hr_16t4_mux
inv clk_inv(.in(clk_halfrate), .out(clk_halfrate_n));
div_b2 div1 (.clkin(clk_halfrate_n), .rst(rst), .clkout(clk_prbsgen));  // 2GHz to 1GHz, output goes to prbs_gen

// Instantiate the output buf
output_buf_tx buf1 (
    .DINN(mtb_n),
    .DINP(mtb_p),
    .CTL_SLICE_N0(tx.ctl_buf_n0),
    .CTL_SLICE_N1(tx.ctl_buf_n1),
    .CTL_SLICE_P0(tx.ctl_buf_p0),
    .CTL_SLICE_P1(tx.ctl_buf_p1),
    .DOUTN(dout_n),
    .DOUTP(dout_p)
);


endmodule

`default_nettype wire
