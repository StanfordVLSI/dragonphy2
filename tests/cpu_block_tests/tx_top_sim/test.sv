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
wire clk_encoder;
logic ctl_valid;
logic clk_oversample;
logic clk_prbschecker;
logic inj_error;
logic prbs_den;
logic [15:0] fixed_pa;
logic [15:0] data;
logic [7:0] count_flag[7:0];

assign data = prbs_den ? prbsdata : fixed_pa;
logic [7:0] record_flag;
logic [15:0] parecord1;
logic [15:0] parecord2;
logic [15:0] parecord3;
logic [15:0] parecord4;
logic [15:0] parecord5;
logic [15:0] parecord6;
logic [15:0] parecord7;
logic [15:0] parecord8;
logic [15:0] parecord9;
logic [15:0] parecord10;
logic [15:0] parecord11;
logic [15:0] parecord12;
logic [15:0] parecord13;
logic [15:0] parecord14;
logic [15:0] parecord15;
logic [15:0] parecord16;



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
                .inj_err(inj_error),
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
    .din(data),
    .mdll_clk(clk_prbschecker),
    .ext_clk(1'b0),
    .ctl_pi(ctl_pi),
    .clk_async(1'b0),
    .clk_encoder(clk_encoder),
    .ctl_valid(ctl_valid),
    .rst(rst),
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


// Testing variable
logic [31:0] err_count;
logic [31:0] error_bits_1;


initial begin

    `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
    `endif
    // Initialize all the nodes
    // Global
    clk_full = 1'b0;
    clk_2 = 1'b0;
    clk_oversample = 1'b0;
    inj_error = 1'b0;
    prbs_den = 1'b0;
    fixed_pa = 16'b0;
    record_flag[0] = 1'b0;
    // clk_encoder =1'b0; 
    rst = 1'b1;
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

    // Configure the Fout phases PI
    ctl_pi[0] = 9'd0;
    ctl_pi[1] = 9'd67;
    ctl_pi[2] = 9'd135;
    ctl_pi[3] = 9'd202;
    //
    ctl_valid = 1'b1;
    #5ns; // After 50 units time, release the enable and reset button
    $display("Releasing reset...");
    rst = 1'b0;
    cke = 1'b1;
    // PI setting
    #5ns;
    $display("Enable the input clock buffer...");
    tx_intf.en_inbuf = 1'b1;
    
    #5ns;
    // Phase interpoator
    $display("Enable phase interpolator...");
    tx_intf.en_gf = 1'b1;
    #5ns;
    $display("Release prbs generator reset..."); // The reset of the prbs must hold unit valid clock are generated and fed into TX
    rst_prbs = 1'b0;  // Otherwise the initall value will not be loaded
    prbs_den = 1'b1;
    #5ns;  // wait 5 ns to avoid initial state error
    
    
    
    // Test case 1 | PRBS test 
    #50ns;
    #15.77ns;
    error_bits_1 = 32'b0;
    err_count = 32'b0;
    // Inject error bits by turning on injerror, 
    inj_error = 1'b0;
    #0.8ns;
    inj_error = 1'b0; 
    #150ns;  // for the counter to finish counting 
    error_bits_1 = err_count;
    //store the error count
    prbs_den = 1'b0;
    #300ns;


    //Check the error bits number injected by inj_err

    $display("error_bits_1: %0d", error_bits_1);
 
    if (error_bits_1 == 0) begin
        $display("No error was detected, Success! (case 1)");
    end else begin
        $error("Error count incorrect (case 1)");
    end
    
    // Test Case 2 fixed pattern
    fixed_pa = 16'b1010101010101010;  // 1,0 repetition, asymmetric
    prbs_den = 1'b0;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[0] = 1'b1;
    #3ns; // stop recording

    $display("parecord1: %b", parecord1);

    if (parecord1 == 16'b1010101010101010) begin
        $display("Pattern deteced, Success! (case 2)");
    end else begin
        $error("Pattern lost (case 2)");
    end

    // Test Case 3 fixed pattern
    fixed_pa = 16'b1010101001010101; // 1,0 repetition, mirrored in middle
    prbs_den = 1'b0;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[1] = 1'b1;
    #3ns; // stop recording

    $display("parecord2: %b", parecord2);

    if (parecord2 == 16'b1010101001010101) begin
        $display("Pattern deteced, Success! (case 3)");
    end else begin
        $error("Pattern lost (case 3)");
    end

    // Test Case 4 fixed pattern
    fixed_pa = 16'b1101001111110011;  // 
    prbs_den = 1'b0;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[2] = 1'b1;
    #3ns; // stop recording

    $display("parecord3: %b", parecord3);

    if (parecord3 == 16'b1101001111110011) begin
        $display("Pattern deteced, Success! (case 4)");
    end else begin
        $error("Pattern lost (case 4)");
    end

    // Test Case 5 fixed pattern
    fixed_pa = 16'b1100100000000011;  //
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[3] = 1'b1;
    #3ns; // stop recording

    $display("parecord4: %b", parecord4);

    if (parecord4 == 16'b1100100000000011) begin
        $display("Pattern deteced, Success! (case 5)");
    end else begin
        $error("Pattern lost (case 5)");
    end

    // Test Case 6 fixed pattern
    fixed_pa = 16'b101110010101011;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[4] = 1'b1;
    #3ns; // stop recording

    $display("parecord5: %b", parecord5);

    if (parecord5 == 16'b101110010101011) begin
        $display("Pattern deteced, Success! (case 6)");
    end else begin
        $error("Pattern lost (case 6)");
    end

    // Test Case 7 fixed pattern
    fixed_pa = 16'b101010001111011;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[5] = 1'b1;
    #3ns; // stop recording

    $display("parecord6: %b", parecord6);

    if (parecord6 == 16'b101010001111011) begin
        $display("Pattern deteced, Success! (case 7)");
    end else begin
        $error("Pattern lost (case 7)");
    end

    // Test Case 8 fixed pattern
    fixed_pa = 16'b101010010101011;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[6] = 1'b1;
    #3ns; // stop recording

    $display("parecord7: %b", parecord7);

    if (parecord7 == 16'b101010010101011) begin
        $display("Pattern deteced, Success! (case 8)");
    end else begin
        $error("Pattern lost (case 8)");
    end

    // Test Case 9 fixed pattern
    fixed_pa = 16'b101011001111011;
    //wait for 2 ns
    #1.1ns; // record flag on
    record_flag[7] = 1'b1;
    #3ns; // stop recording

    $display("parecord8: %b", parecord8);

    if (parecord8 == 16'b101011001111011) begin
        $display("Pattern deteced, Success! (case 9)");
    end else begin
        $error("Pattern lost (case 9)");
    end



    #2ns $finish;
end
    
    // always #0.625 clk_a = ~clk_a; // #5 for 1 GHz
    always #(0.0625ns) clk_full <= ~clk_full; // 8GHz
    always #(0.5ns) clk_2 <= ~clk_2; // clk_encoder to load the 
    always #(0.03125ns) clk_oversample <= ~clk_oversample; // Clock for prbs checker core
    //Error number counter 
    always @(posedge clk_oversample) begin
        if (rst) begin
            inj_error <= 0;
            error_bits_1 <= 32'b0;
            err_count <= 32'b0;
        end else if (err_flag && prbs_den) begin
            err_count += 1'b1;
        end
    end

    // Counter initialization
    always @(posedge clk_prbs) begin
        if (rst) begin
            count_flag[0] <= 8'b0;
            count_flag[1] <= 8'b0;
            count_flag[2] <= 8'b0;
            count_flag[3] <= 8'b0;
            count_flag[4] <= 8'b0;
            count_flag[5] <= 8'b0;
            count_flag[6] <= 8'b0;
            count_flag[7] <= 8'b0;
        end else if (record_flag[0]) begin
            #0.5ns;  // Manually align the count down with the first bit of the data output, this delay should be fixed if no circuit connection has changed
            count_flag[0] = 8'd16; // determine how many bits to store in the shift reg
            record_flag[0] = 1'b0;
        end else if (record_flag[1]) begin
            #0.5ns;
            count_flag[1] = 8'd16;
            record_flag[1] = 1'b0;
        end else if (record_flag[2]) begin
            #0.5ns;
            count_flag[2] = 8'd16;
            record_flag[2] = 1'b0;
        end else if (record_flag[3]) begin
            #0.5ns;
            count_flag[3] = 8'd16;
            record_flag[3] = 1'b0;
        end else if (record_flag[4]) begin
            #0.5ns;
            count_flag[4] = 8'd16;
            record_flag[4] = 1'b0;
        end else if (record_flag[5]) begin
            #0.5ns;
            count_flag[5] = 8'd16;
            record_flag[5] = 1'b0;
        end else if (record_flag[6]) begin
            #0.5ns;
            count_flag[6] = 8'd16;
            record_flag[6] = 1'b0;
        end else if (record_flag[7]) begin
            #0.5ns;
            count_flag[7] = 8'd16;
            record_flag[7] = 1'b0;
        end
    end

    //Pattern recording
    always @(posedge clk_oversample) begin
        if (rst) begin
            parecord1 <= 16'h0000;
            parecord2 <= 16'h0000;
            parecord3 <= 16'h0000;
            parecord4 <= 16'h0000;
            parecord5 <= 16'h0000;
            parecord6 <= 16'h0000;
            parecord7 <= 16'h0000;
            parecord8 <= 16'h0000;
        end else if ((!prbs_den) && (count_flag[0] > 0)) begin
            //shift register
            parecord1 <= {dout_p, parecord1[15:1]};  // Right shift to store the 16-bit data package in the correct order
            count_flag[0] -= 1;
        end else if ((!prbs_den) && (count_flag[1] > 0)) begin
            //shift register
            parecord2 <= {dout_p, parecord2[15:1]};
            count_flag[1] -= 1;
        end else if ((!prbs_den) && (count_flag[2] > 0)) begin
            //shift register
            parecord3 <= {dout_p, parecord3[15:1]};
            count_flag[2] -= 1;
        end else if ((!prbs_den) && (count_flag[3] > 0)) begin
            //shift register
            parecord4 <= {dout_p, parecord4[15:1]};
            count_flag[3] -= 1;
        end  else if ((!prbs_den) && (count_flag[4] > 0)) begin
            //shift register
            parecord5 <= {dout_p, parecord5[15:1]};
            count_flag[4] -= 1;
        end else if ((!prbs_den) && (count_flag[5] > 0)) begin
            //shift register
            parecord6 <= {dout_p, parecord6[15:1]};
            count_flag[5] -= 1;
        end else if ((!prbs_den) && (count_flag[6] > 0)) begin
            //shift register
            parecord7 <= {dout_p, parecord7[15:1]};
            count_flag[6] -= 1;
        end else if ((!prbs_den) && (count_flag[7] > 0)) begin
            //shift register
            parecord8 <= {dout_p, parecord8[15:1]};
            count_flag[7] -= 1;
        end
    end 


endmodule

`default_nettype wire
