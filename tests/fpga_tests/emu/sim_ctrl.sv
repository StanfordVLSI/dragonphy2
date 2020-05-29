`timescale 1s/1fs

`define MM_PD_I top.tb_i.rx_i.mm_pd_i
`define INIT_MARGIN 1000
`define UPDATE_RATE 250
`define UPDATE_RATE_TIME 1000e-6

module sim_ctrl(
    input wire logic [7:0] lb_latency,
    input wire logic [63:0] lb_correct_bits,
    input wire logic [63:0] lb_total_bits,
    input wire logic data_rx,
    input wire logic mem_rd,
    output var logic prbs_rst=1'b1,
    output var logic rx_rstb=1'b0,
    output var logic [1:0] lb_mode=2'b00,
    output var logic [31:0] tm_stall=27'h3FFFFFF
);
    logic [7:0] lb_latency_local;
    logic [63:0] lb_correct_bits_local;
    logic [63:0] lb_total_bits_local;

    initial begin
        // Uncomment to dump all waveforms (significantly slows down simulation)
        // $dumpvars(0, top);

        // wait for emulator reset to complete
        $display("Waiting for emulator reset to complete...");
        #(10us);

        // initialize signals
        $display("Initializing signals...");
        tm_stall = 27'h3FFFFFF;
        rx_rstb = 1'b0;
        prbs_rst = 1'b1;
        lb_mode = 2'b00;
        #(1us);

        // Take the RX out of reset
        $display("Taking the RX out of reset...");
        rx_rstb = 1'b1;
        prbs_rst = 1'b0;
        #(2500us);

        // Align the loopback tester
        $display("Aligning the loopback tester...");
        lb_mode = 2'b01;
        #(700us);
        $display("Loopback latency: %0d cycles.", lb_latency);

        // run the loopback test
        lb_mode = 2'b10;
        #(5500us);

        // halt emulation
        tm_stall = 27'h0000000;
        #(10us);

        // read results
        lb_correct_bits_local = lb_correct_bits;
        #(10us);
        lb_total_bits_local = lb_total_bits;
        #(10us);

        // print results
        $display("Loopback correct bits: %0d.", lb_correct_bits_local);
        $display("Loopback total bits: %0d.", lb_total_bits_local);

        // check results
        assert (lb_total_bits_local >= 10000) else
            $error("Not enough total bits transmitted.");
        assert (lb_total_bits_local == lb_correct_bits_local) else
            $error("Bit error detected.");
        $finish;
    end

    // Simulation debugging
    integer count=0, curr_margin=0, min_margin=`INIT_MARGIN;
    always @(posedge `MM_PD_I.clk) begin
        count = count + 1;
        curr_margin = `MM_PD_I.val * `MM_PD_I.data_i;
        min_margin = (curr_margin < min_margin) ? curr_margin : min_margin;
        if (count == `UPDATE_RATE) begin
            $display("pi_ctl: %0d, min_margin: %0d", `MM_PD_I.pi_ctl, min_margin);
            count = 0;
            min_margin = `INIT_MARGIN;
        end
    end
    always begin
        $display("time: %0f us", $realtime*1e6);
        #(`UPDATE_RATE_TIME * 1s);
    end
endmodule
