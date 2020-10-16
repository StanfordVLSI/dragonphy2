`timescale 100ps/1ps   //  unit_time / time precision
`include "iotype.sv"

module tx_top import const_pack::*; #(
)(
    input wire [15:0] din,
    input wire mdll_clk, // Clock from MDLL
    input wire ext_clk, // Clock from external source

    input wire rst, // Global reset for Tx
    input wire cke, // Gloabl lock gating for Tx
    input wire logic [Npi-1:0] ctl_pi[Nout-1:0],
    input wire logic clk_async,
    output wire logic clk_encoder,
    input wire logic ctl_valid,

    // output reg tx.inbuf_out_meas,
    output wire clk_prbsgen,  // Output clock for 16-bit prbs generator
    output wire dout_p, // Data output
    output wire dout_n,
    tx_debug_intf.tx tx
    );

//This Tx top specify the connect between qr_4t1_mux_top and hr_16t4_mux_top

// Instantiate half-rate 16 to 4 mux top
wire [3:0] qr_data_p;  // Output of 16 to 4 mux, positive
wire [3:0] qr_data_n;  // Output of 16 to 4 mux, negative
wire clk_halfrate_n;
wire clk_halfrate;  // Input clock for 16 to 4 mux

wire [3:0] clk_interp_slice; // Output from the phase interpolator
wire [3:0] clk_interp_sw; //

wire clk_in_pi;

// Global reset 
wire rstb;
assign rstb = ~ rst;

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
                .en_gf(tx.en_gf),
                .en_arb(tx.en_arb_pi[k]),
                .en_delay(tx.en_delay_pi[k]),
                .en_ext_Qperi(tx.en_ext_Qperi[k]),
                .en_pm(tx.en_pm_pi[k]),
                .en_cal(tx.en_cal_pi[k]),

                .en_unit(en_unit_pi[k]), // en_unit_pi added

                .ext_Qperi(tx.ext_Qperi[k]),
                .sel_pm_sign(tx.sel_pm_sign_pi[k]),
                .inc_del(tx.del_inc[k]),
                .ctl_dcdl_slice(tx.ctl_dcdl_slice[k]),
                .ctl_dcdl_sw(tx.ctl_dcdl_sw[k]),
                .ctl_dcdl_clk_encoder(tx.ctl_dcdl_clk_encoder[k]),
                .disable_state(tx.disable_state[k]),
                .en_clk_sw(tx.en_clk_sw[k]),
                // portion 3 checked | Yes
                //outputs
                .clk_out_slice(clk_interp_slice[k]),
                .clk_out_sw(clk_interp_sw[k]),
                .Qperi(tx.Qperi[k]),
                .cal_out(tx.cal_out_pi[k]),
                .del_out(inv_del_out_pi[k]),
                .pm_out(tx.pm_out_pi[k]),
                .max_sel_mux(tx.max_sel_mux[k]),
                .cal_out_dmm()
            );
            // portion 4 checked | Yes
            assign tx.pi_out_meas[k] = (tx.sel_meas_pi[k] ? clk_interp_slice[k] : clk_interp_sw[k]) & tx.en_meas_pi[k];
            assign en_unit_pi[k] = ~tx.enb_unit_pi[k];  
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
    .din(din),
    .rst(rst), 
    .dout(qr_data_p),
    .clk_b2(clk_prbsgen)  // This clk_halfrate 
);

//Instantiate quarter-rate 4 to 1 mux top
qr_4t1_mux_top qr_mux_4t1_0 (
    .clk_Q(clk_interp_slice[0]),  // Quarter-rate clock input
    .clk_QB(clk_interp_slice[2]),
    .clk_I(clk_interp_slice[1]),
    .clk_IB(clk_interp_slice[3]),
    .din(qr_data_p), // Quarter-rate data from half-rate 16 to 4 mux
    .rst(rst),
    .ck_b2(clk_halfrate), // Divided quarter-rate clock for 16 to 4 mux
    .data(dout_p) // Final data output + positive Output driver and termination needs to be added 
);

// Data - negative
hr_16t4_mux_top hr_mux_16t4_1 (
    .clk_hr(clk_halfrate_n), // This is a divided (by 2) clock from quarter-rate 4 to 1 mux
    .din(~din), // Inverting the data input for differential output
    .rst(rst),
    .dout(qr_data_n),
    .clk_b2()  // This is a residue clock signal 
);

//Instantiate quarter-rate 4 to 1 mux top
qr_4t1_mux_top qr_mux_4t1_1 (
    .clk_Q(clk_interp_slice[0]),  // Quarter-rate clock input
    .clk_QB(clk_interp_slice[2]),
    .clk_I(clk_interp_slice[1]),
    .clk_IB(clk_interp_slice[3]),
    .din(qr_data_n), // Quarter-rate data from half-rate 16 to 4 mux
    .rst(rst),
    .ck_b2(clk_halfrate_n), // Divided quarter-rate clock for 16 to 4 mux
    .data(dout_n) // Final data output - negative Output driver and termination needs to be added
);

endmodule


