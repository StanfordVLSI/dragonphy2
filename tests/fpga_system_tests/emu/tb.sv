`include "iotype.sv"

`ifndef FUNC_DATA_WIDTH
    `define FUNC_DATA_WIDTH 18
`endif

`ifndef FUNC_NUMEL
    `define FUNC_NUMEL 2048
`endif


`ifndef TC
    `define TC 4e-9
`endif


module tb;
    //////////////////
    // External IOs //
    //////////////////

    (* dont_touch = "true" *) logic rstb;
    (* dont_touch = "true" *) logic dump_start;

    (* dont_touch = "true" *) logic tdi;
    (* dont_touch = "true" *) logic tdo;
    (* dont_touch = "true" *) logic tck;
    (* dont_touch = "true" *) logic tms;
    (* dont_touch = "true" *) logic trst_n;

    ////////////////////
    // JTAG Interface //
    ////////////////////

    jtag_intf jtag_intf_i ();
    assign jtag_intf_i.phy_tdi = tdi;
    assign tdo = jtag_intf_i.phy_tdo;
    assign jtag_intf_i.phy_tck = tck;
    assign jtag_intf_i.phy_tms = tms;
    assign jtag_intf_i.phy_trst_n = trst_n;

    ////////////////////
    //  Emulator I/O  //
    ////////////////////

    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;
    (* dont_touch = "true" *) `DECL_DT(emu_dt);
    (* dont_touch = "true" *) `DECL_DT(dt_req);
    (* dont_touch = "true" *) logic [6:0] jitter_rms_int;
    (* dont_touch = "true" *) logic [10:0] noise_rms_int;
    (* dont_touch = "true" *) logic [31:0] prbs_eqn;
    (* dont_touch = "true" *) logic [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_0;
    (* dont_touch = "true" *) logic [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_1;
    (* dont_touch = "true" *) logic [$clog2(`FUNC_NUMEL)-1:0] chan_waddr;
    (* dont_touch = "true" *) logic chan_we;

    //////////////
    // TX clock //
    //////////////

    (* dont_touch = "true" *) logic clk_tx_val_posedge;
    my_edgedet det_i (
        .val(clk_tx_val),
        .clk(emu_clk),
        .rst(emu_rst),
        .edge_p(clk_tx_val_posedge),
        .edge_n()
    );

    `DECL_DT(t_lo);
    `ASSIGN_CONST_REAL(31.25e-12, t_lo);

    `DECL_DT(t_hi);
    `ASSIGN_CONST_REAL(31.25e-12, t_hi);

    (* dont_touch = "true" *) osc_model_core #(
        `PASS_REAL(t_lo, t_lo),
        `PASS_REAL(t_hi, t_hi),
        `PASS_REAL(emu_dt, emu_dt),
        `PASS_REAL(dt_req, dt_req)
    ) tx_clk_i (
        .emu_rst(emu_rst),
        .emu_clk(emu_clk),
        .t_lo(t_lo),
        .t_hi(t_hi),
        .emu_dt(emu_dt),
        .dt_req(dt_req),
        .clk_val(clk_tx_val)
    );

    /////////////////
    // Transmitter //
    /////////////////

    (* dont_touch = "true" *) logic data_tx_i;
    (* dont_touch = "true" *) `DECL_PWL(data_tx_o);

    (* dont_touch="true" *) tx_core #(
        `PASS_REAL(out, data_tx_o)
    ) tx_core_i (
        .in_(data_tx_i),
        .out(data_tx_o),
        .cke(clk_tx_val),
        .clk(emu_clk),
        .rst(emu_rst)
    );

    /////////////
    // Channel //
    /////////////

    (* dont_touch = "true" *) `DECL_PWL(data_rx_i);

    (* dont_touch = "true" *) chan_core #(
        `PASS_REAL(in_, data_tx_o),
        `PASS_REAL(out, data_rx_i),
        `PASS_REAL(dt_sig, emu_dt)
    ) chan_i (
        .in_(data_tx_o),
        .out(data_rx_i),
        .dt_sig(emu_dt),
        .clk(emu_clk),
        .rst(emu_rst),
        .cke(clk_tx_val_posedge),
        // runtime-defined function controls
        .wdata0(chan_wdata_0),
        .wdata1(chan_wdata_1),
        .waddr(chan_waddr),
        .we(chan_we)
    );

    ///////////////////
    // Clock divider //
    ///////////////////

    (* dont_touch = "true" *) logic ext_clkp;

    // divide 16 GHz clock by two to get 8 GHz clock
    logic div_state;
    assign ext_clkp = clk_tx_val_posedge ? ~div_state : div_state;
    always @(posedge emu_clk) begin
        if (emu_rst == 1'b1) begin
            div_state <= 1'b0;
        end else if (clk_tx_val_posedge) begin
            div_state <= ~div_state;
        end else begin
            div_state <= div_state;
        end
    end

    ////////////////
    // Top module //
    ////////////////

    (* dont_touch = "true" *) dragonphy_top top_i (
        // analog inputs
        .ext_rx_inp(data_rx_i),
        .ext_rx_inn(0),

        // clock inputs
        .ext_clkp(ext_clkp),
        .ext_clkn(1'b0),

        // reset
        .ext_rstb(rstb),

        // SRAM dump
        .ext_dump_start(dump_start),

        // JTAG
        .jtag_intf_i(jtag_intf_i)

        // other I/O not used..
    );

    //////////
    // PRBS //
    //////////

    (* dont_touch = "true" *) prbs_generator_syn #(
        .n_prbs(32)
    ) prbs_generator_syn_i (
        .clk(emu_clk),
        .rst(emu_rst),
        .cke(clk_tx_val_posedge),
        .init_val(32'h00000001),
        .eqn(prbs_eqn),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(data_tx_i)
    );

    ///////////////
    // ADC noise //
    ///////////////

    // calculate scale factor
    `MAKE_REAL(noise_rms, 250e-3);
    `INT_TO_REAL({1'b0, noise_rms_int}, 12, noise_rms_real);
    `MUL_CONST_INTO_REAL(0.1e-3, noise_rms_real, noise_rms);

    // write scale factor into hierarchy
    // value for each ADC is set separately due to synthesis limitations;
    // putting these assignments in a generate loop seems to create a
    // multiply-driven net.
    assign top_i.iacore.iADC[0].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[1].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[2].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[3].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[4].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[5].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[6].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[7].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[8].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[9].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[10].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[11].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[12].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[13].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[14].iADC.noise_rms = noise_rms;
    assign top_i.iacore.iADC[15].iADC.noise_rms = noise_rms;

    // set random seeds in a similar fashion
    // print(f"32'h{random.randint(0, (1<<32)-1):08x}")
    assign top_i.iacore.iADC[0].iADC.noise_seed  = 32'hcc37e574;
    assign top_i.iacore.iADC[1].iADC.noise_seed  = 32'he967ed2e;
    assign top_i.iacore.iADC[2].iADC.noise_seed  = 32'h926efedc;
    assign top_i.iacore.iADC[3].iADC.noise_seed  = 32'h9e873f52;
    assign top_i.iacore.iADC[4].iADC.noise_seed  = 32'h2ab0aafa;
    assign top_i.iacore.iADC[5].iADC.noise_seed  = 32'hb61849f5;
    assign top_i.iacore.iADC[6].iADC.noise_seed  = 32'hc88ee432;
    assign top_i.iacore.iADC[7].iADC.noise_seed  = 32'h2b855bae;
    assign top_i.iacore.iADC[8].iADC.noise_seed  = 32'h5b646081;
    assign top_i.iacore.iADC[9].iADC.noise_seed  = 32'h69dc28be;
    assign top_i.iacore.iADC[10].iADC.noise_seed = 32'h48031e36;
    assign top_i.iacore.iADC[11].iADC.noise_seed = 32'hfe712f71;
    assign top_i.iacore.iADC[12].iADC.noise_seed = 32'h6e67c14c;
    assign top_i.iacore.iADC[13].iADC.noise_seed = 32'h4a64eb5e;
    assign top_i.iacore.iADC[14].iADC.noise_seed = 32'hbd08afd1;
    assign top_i.iacore.iADC[15].iADC.noise_seed = 32'hc673c47e;

    ///////////////
    // PI jitter //
    ///////////////

    // calculate scale factor
    `MAKE_REAL(jitter_rms, 15e-12);
    `INT_TO_REAL({1'b0, jitter_rms_int}, 8, jitter_rms_real);
    `MUL_CONST_INTO_REAL(0.1e-12, jitter_rms_real, jitter_rms);

    // write scale factor into hierarchy
    // value for each PI is set separately due to synthesis limitations;
    // putting these assignments in a generate loop seems to create a
    // multiply-driven net.
    assign top_i.iacore.iPI[0].iPI.jitter_rms = jitter_rms;
    assign top_i.iacore.iPI[1].iPI.jitter_rms = jitter_rms;
    assign top_i.iacore.iPI[2].iPI.jitter_rms = jitter_rms;
    assign top_i.iacore.iPI[3].iPI.jitter_rms = jitter_rms;

    // set random seeds in a similar fashion
    // print(f"32'h{random.randint(0, (1<<32)-1):08x}")
    assign top_i.iacore.iPI[0].iPI.jitter_seed = 32'h2406e5ea;
    assign top_i.iacore.iPI[1].iPI.jitter_seed = 32'hf7afc1bf;
    assign top_i.iacore.iPI[2].iPI.jitter_seed = 32'h75fbb26c;
    assign top_i.iacore.iPI[3].iPI.jitter_seed = 32'h7d4439cd;

endmodule
