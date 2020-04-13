`include "mLingua_pwl.vh"
`include "iotype.sv"
`default_nettype none
`define PULSE_HIGH(signal) \
    signal = 1'b1; \
    #0; \
    signal = 1'b0

module test;

    import const_pack::*;
    import test_pack::*;
    import checker_pack::*;
    import jtag_reg_pack::*;

    localparam integer Nin = 1;          // number of PI input clock phases
    localparam integer Nblender = 4;     // number of phase blender control bits
    localparam real Twait = 1e-9;
    localparam `real_t v_cm = 0.40;

    // signal declaration
    PWLMethod pm=new;

    // Analog inputs
    `pwl_t ch_outp;
    `pwl_t ch_outn;
    //`real_t v_cm;
    `voltage_t v_cal;

    // clock inputs 
    logic clk_async;
    logic clk_jm_p;
    logic clk_jm_n;
    logic ext_clkp;
    logic ext_clkn;
    logic signed [Nadc-1:0] adcout_conv_signed [Nti-1:0];
    // clock outputs
    logic clk_out_p;
    logic clk_out_n;
    logic clk_trig_p;
    logic clk_trig_n;
    logic clk_retime;
    logic clk_slow;
    logic rstb;
    // dump control
    logic dump_start;
    logic clk_cdr;
    // JTAG
    jtag_intf jtag_intf_i();

    wire logic [Nout-1:0] clk_interp;
    reg [Npi-1:0] pi_ctl [Nout-1:0];
    reg [Npi-1:0] temp;
    real Tdelay [Nout-1:0];

    // Instantiate blocks per output

    genvar i;
    generate
        for (i=0; i<Nout; i=i+1) begin
            delay_meas_ideal idmeas (
                .ref_in(top_i.iacore.clk_in_pi),
                .in(top_i.iacore.clk_interp_sw[i]),
                .delay(Tdelay[i])
            );
        end
    endgenerate

    // instantiate top module
    butterphy_top top_i (
        // analog inputs
        .ext_rx_inp(ch_outp),
        .ext_rx_inn(ch_outn),
        .ext_Vcm(v_cm),
        .ext_Vcal(v_cal),

        // clock inputs 
        .ext_clkp(ext_clkp),
        .ext_clkn(ext_clkn),

        // clock outputs
        .clk_out_p(clk_out_p),
        .clk_out_n(clk_out_n),
        .clk_trig_p(clk_trig_p),
        .clk_trig_n(clk_trig_n),
        // dump control
        .ext_dump_start(dump_start),
        .ext_rstb(rstb),
        // JTAG
        .jtag_intf_i(jtag_intf_i)
    );


    clock #(
        .freq(full_rate/2), //Depends on divider !
        .duty(0.5),
        .td(0)
    ) iEXTCLK (
        .ckout(ext_clkp),
        .ckoutb(ext_clkn)
    ); 

    jtag_drv jtag_drv_i (jtag_intf_i);

    // Recording

    logic record;

    pi_ctl_recorder pi_ctl_recorder_i(
    	.in(pi_ctl),
    	.en(1'b1),
    	.clk(record)
    );

    delay_recorder delay_recorder_i(
    	.in(Tdelay),
    	.en(1'b1),
    	.clk(record)
    );

    // Main test logic

    logic [Npi-1:0] pi_ctl_stim [Nout-1:0] [(2**Npi-1):0];
    initial begin

        record = 1'b0;
        #(20ns);
        rstb = 1'b0;
        #(20ns);
        rstb = 1'b1;
        #(10ns);

        // Initialize JTAG
        jtag_drv_i.init();

        // Enable the input buffer
        //jtag_drv_i.write_tc_reg(en_inbuf, 'b1);
        //jtag_drv_i.write_tc_reg(int_rstb, 'b1);
        force top_i.idcore.adbg_intf_i.en_inbuf='d1;
        force top_i.idcore.ddbg_intf_i.int_rstb ='d1;
        force top_i.idcore.ddbg_intf_i.Ndiv_clk_cdr = 'd1;
        //jtag_drv_i.write_tc_reg(Ndiv_clk_cdr, 'd1); //  Reduce the CDR clock division so that the simulation time isn't so egregious

        //PI has an erroneous state due to its relationship with the clock that produces the CDR clock
        //If value goes above ~375, the PI produces a clock output that has a duty cycle issue (?) that then causes
        //the clk_adc to drop to half rate and the clock cdr to drop to half that...
        for (int i=0; i<Nout; i=i+1) begin
            temp = $random;
            pi_ctl[i] = temp;//(temp > 375) ? 374 : temp;
        end
        force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[0] = pi_ctl[0];
        force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[1] = pi_ctl[1];
        force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[2] = pi_ctl[2];
        force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[3] = pi_ctl[3];
    //end

        // compute stimulus

        for (int i=0; i<Nout; i=i+1) begin
            //for (int j=240; j<340; j=j+1) begin
            for (int j=0; j<2**Npi; j=j+1) begin
                pi_ctl_stim[i][j] = j;
            end
            //pi_ctl_stim[i].shuffle(); 
        end

        // wait for startup
        jtag_drv_i.write_tc_reg(en_v2t, 'b1);

        #(100ns);

        // run desired number of trials
        //for (int j=0; j<2**Npi; j=j+1) begin
        for (int i=0; i<2**Npi; i=i+1) begin
                    //for (int i=0; i<Nout; i=i+1) begin
            pi_ctl[0] = pi_ctl_stim[0][i];
            pi_ctl[1] = pi_ctl_stim[1][i];
            pi_ctl[2] = pi_ctl_stim[2][i];
            pi_ctl[3] = pi_ctl_stim[3][i];
            repeat (3) @(negedge top_i.idcore.clk_cdr);
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[0] = pi_ctl[0];
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[1] = pi_ctl[1];
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[2] = pi_ctl[2];
            force top_i.idcore.ddbg_intf_i.ext_pi_ctl_offset[3] = pi_ctl[3];
                //end
 //           #(Twait*1s);
            `PULSE_HIGH(record);
        end

        #(Twait*1s);

        $finish;
    end

    initial begin
    	// initialize


    end

    // print simulation status

    sim_status sim_status_i();

endmodule

`default_nettype wire
