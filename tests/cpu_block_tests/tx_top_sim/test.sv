`timescale 1fs/1fs   //  Unit_time / Time precision
`default_nettype none
module test (
    output wire logic dout_p,
    output wire logic dout_n   // din to dout, X2
); // Module declaration


tx_debug_intf tx_intf ();  // Tx debug interfaces
//Internal variables
logic [15:0] prbsdata;  //Output of the prbs generator
logic clk_prbs; // Clock for prbs generator
logic rst;  // Reset signal
logic rst_prbs;

logic clk_full; // Full rate clock for prbs_checker 16GBps -> 16GHz
logic cke;
logic [9-1:0] ctl_pi[3:0];
reg clk_2;  // Clock clk_a divided by 2
logic clk_async;
wire clk_encoder;
logic ctl_valid;
logic clk_oversample;
logic clk_prbschecker;

logic err_flag; 

    logic [31:0] init_vals [16];
    assign init_vals[0]  = 32'h0ffd4066;
    assign init_vals[1]  = 32'h38042b00;
    assign init_vals[2]  = 32'h001fffff;
    assign init_vals[3]  = 32'h39fbfe59;
    assign init_vals[4]  = 32'h1ffd40cc;
    assign init_vals[5]  = 32'h3e055e6a;
    assign init_vals[6]  = 32'h03ff554c;
    assign init_vals[7]  = 32'h3e0aa195;
    assign init_vals[8]  = 32'h1f02aa60;
    assign init_vals[9]  = 32'h31f401f3;
    assign init_vals[10] = 32'h00000555;
    assign init_vals[11] = 32'h300bab55;
    assign init_vals[12] = 32'h1f05559f;
    assign init_vals[13] = 32'h3f8afe65;
    assign init_vals[14] = 32'h07ff5566;
    assign init_vals[15] = 32'h7f8afccf;

    genvar i;  // Declare the generate variable
    generate
        for(i=0; i<16; i=i+1) begin
            prbs_generator_syn #(
                .n_prbs(32)
            ) prbs_b (
                .clk(clk_prbs),
                .rst(rst_prbs),
                .cke(1'b1),
                .init_val(init_vals[i]),
                .eqn(32'h100002),
                .inj_err(1'b0),
                .inv_chicken(2'b00),
                .out(prbsdata[i])
            );
        end
    endgenerate

// Instantiate a one bit prbs_checker
prbs_checker_core #(
        .n_prbs(32)
    ) u0 (
    .clk(clk_oversample),
    .rst(rst),
    .cke(1'b1),
    .eqn(32'h100002),
    .inv_chicken(2'b00),
    .rx_bit(dout_p),
    .err(err_flag)
);

tx_top tx_mux (
    .din(prbsdata),
    .mdll_clk(clk_prbschecker),
    .ext_clk(1'b0),
    .ctl_pi(ctl_pi),
    .clk_async(clk_async),
    .clk_encoder(clk_encoder),
    .ctl_valid(ctl_valid),
    .clk_prbsgen(clk_prbs),  // Output clock for 16-bit prbs generator
    .dout_p(dout_p),
    .dout_n(dout_n),
    .tx(tx_intf)
);

assign clk_encoder = clk_2;

div_b2 divb2 (.clkin(clk_oversample), .rst(rst), .clkout(clk_prbschecker));

//This phase interpolator takes a 8GHz clock to generate 4-phase 4GHz clock
// fppi pi(.clkin(clk_a), .clk_Q(cq), .clk_I(ci), .clk_QB(cqb), .clk_IB(cib));
// div_b2 div0(.clkin(clk_full), .clkout(clk_a));


initial begin

    `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
    `endif

    // clk_a  = 1'b0;
    // Initialize all the nodes
    //Global
    clk_full = 1'b0;
    clk_2 = 1'b0;
    clk_oversample = 1'b0;
    // clk_encoder =1'b0; 
    rst = 1'b1;
    tx_intf.rst = 1'b1;
    tx_intf.cke = 1'b1;
    cke = 1'b1;
    rst_prbs = 1'b1;
    #3ns;

    // Input divider
    tx_intf.en_inbuf = 1'b0;
    tx_intf.sel_clk_source = 1'b0;
    tx_intf.bypass_inbuf_div = 1'b0;
    tx_intf.bypass_inbuf_div2 = 1'b0;
    tx_intf.inbuf_ndiv = 3'd0;
    tx_intf.en_inbuf_meas = 1'b0;
    tx_intf.sel_del_out_pi = 1'b0;
    tx_intf.en_del_out_pi = 1'b0;
    // Phase interpoator
    tx_intf.en_gf = 1'b0;
    tx_intf.en_arb_pi = 4'hf;
    tx_intf.en_delay_pi = 4'hf;
    tx_intf.en_ext_Qperi = 4'h0;
    tx_intf.en_pm_pi = 4'h0;
    tx_intf.en_cal_pi = 4'h0;
    tx_intf.en_clk_sw = 4'hf;
    tx_intf.en_meas_pi = 4'h0;
    
    ctl_valid = 0;

    tx_intf.ext_Qperi[0] = 5'b10001;
    tx_intf.ext_Qperi[1] = 5'b10001;
    tx_intf.ext_Qperi[2] = 5'b10001;
    tx_intf.ext_Qperi[3] = 5'b10001;

    tx_intf.sel_pm_sign_pi[0] = 2'b00;
    tx_intf.sel_pm_sign_pi[1] = 2'b00;
    tx_intf.sel_pm_sign_pi[2] = 2'b00;
    tx_intf.sel_pm_sign_pi[3] = 2'b00;
    tx_intf.del_inc[0] = 32'h0;
    tx_intf.del_inc[1] = 32'h0;
    tx_intf.del_inc[2] = 32'h0;
    tx_intf.del_inc[3] = 32'h0;
    tx_intf.enb_unit_pi[0] = 32'h0;
    tx_intf.enb_unit_pi[1] = 32'h0;
    tx_intf.enb_unit_pi[2] = 32'h0;
    tx_intf.enb_unit_pi[3] = 32'h0;
    tx_intf.disable_state = 4'h0; 
    tx_intf.sel_meas_pi = 4'h0;


    tx_intf.ctl_dcdl_slice[0] = 2'b00; 
    tx_intf.ctl_dcdl_slice[1] = 2'b00;
    tx_intf.ctl_dcdl_slice[2] = 2'b00; 
    tx_intf.ctl_dcdl_slice[3] = 2'b00;
    tx_intf.ctl_dcdl_sw[0] = 2'b00;
    tx_intf.ctl_dcdl_sw[1] = 2'b00;
    tx_intf.ctl_dcdl_sw[2] = 2'b00;
    tx_intf.ctl_dcdl_sw[3] = 2'b00;
    tx_intf.ctl_dcdl_clk_encoder[0] = 2'b00;
    tx_intf.ctl_dcdl_clk_encoder[1] = 2'b00;
    tx_intf.ctl_dcdl_clk_encoder[2] = 2'b00;
    tx_intf.ctl_dcdl_clk_encoder[3] = 2'b00;

    tx_intf.sel_clk_source = 1'b1;
    tx_intf.bypass_inbuf_div = 1'b1;
    tx_intf.bypass_inbuf_div2 = 1'b0;
    tx_intf.inbuf_ndiv = 3'd1;
    tx_intf.en_inbuf_meas = 1'b0;

    tx_intf.sel_del_out_pi = 1'b0;
    tx_intf.en_del_out_pi = 1'b1;


    ctl_pi[0] = 9'd0;
    ctl_pi[1] = 9'd67;
    ctl_pi[2] = 9'd135;
    ctl_pi[3] = 9'd202;

    ctl_valid = 1'b1;
    #5ns; // After 50 units time, release the enable and reset button
    rst = 1'b0;
    cke = 1'b1;
    tx_intf.rst = 1'b0;
    tx_intf.cke = 1'b1;
    // PI setting
    #5ns;
    tx_intf.en_inbuf = 1'b1;
    #5ns;
    // Phase interpoator
    tx_intf.en_gf = 1'b1;
    #5ns;
    rst_prbs = 1'b0;
    #5ns;

    // tx_intf.en_arb_pi = 4'hf;
    // tx_intf.en_delay_pi = 4'hf;
    // tx_intf.en_ext_Qperi = 4'h0;
    // tx_intf.en_pm_pi = 4'h0;
    // tx_intf.en_cal_pi = 4'h0;
    // tx_intf.en_clk_sw = 4'hf;
    // tx_intf.en_meas_pi = 4'h0;

    // Input clock divider
    
    // tx_intf.sel_clk_source = 1'b1;
    // tx_intf.bypass_inbuf_div = 1'b1;
    // tx_intf.bypass_inbuf_div2 = 1'b0;
    // tx_intf.inbuf_ndiv = 3'd1;
    // tx_intf.en_inbuf_meas = 1'b0;

    // tx_intf.sel_del_out_pi = 1'b0;
    // tx_intf.en_del_out_pi = 1'b1;



    #3ns;
    // rst = 1'b0; // Release the reset button of prbs generator

    //Set the simulation time
    #100ns $finish;
end
    
    // always #0.625 clk_a = ~clk_a; // #5 for 1 GHz
    always #(0.0625ns) clk_full <= ~clk_full; // 8GHz
    always #(0.5ns) clk_2 <= ~clk_2; 
    always #(0.03125ns) clk_oversample <= ~clk_oversample;

endmodule

`default_nettype wire