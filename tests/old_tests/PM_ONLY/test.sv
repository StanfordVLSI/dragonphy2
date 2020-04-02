`include "mLingua_pwl.vh"

`default_nettype none

`ifndef CLK_ASYNC_FREQ
    `define CLK_ASYNC_FREQ 0.501e9
`endif

`ifndef CLK_REF_FREQ
    `define CLK_REF_FREQ 4e9
`endif

module test;

    localparam integer n_tests=100;

    logic ph_ref;
    logic ph_in;
    logic clk_async;
    logic en_pm;
    logic [19:0] pm_out;

    phase_monitor phase_monitor_i (
      .ph_ref(ph_ref),
      .ph_in(ph_in),
      .sel_sign({2'b00}),
      .clk_async(clk_async),
      .en_pm(en_pm),
      .pm_out(pm_out)
    );

    clock #(
        .freq(`CLK_REF_FREQ),
        .duty(0.5),
        .td(0)
    ) i_ph_ref (
        .ckout(ph_ref),
        .ckoutb()
    ); 

    // delay ph_in with respect to ph_ref (transport delay)
    real Tdelay = 0.0;
    always @(ph_ref) begin
        ph_in <= #(Tdelay*1s) ph_ref;
    end

    clock #(
        .freq(`CLK_ASYNC_FREQ),
        .duty(0.5),
        .td(0)
    ) i_clk_async (
        .ckout(clk_async),
        .ckoutb()
    );

    // Recording

    logic record;

    logic_recorder #(
        .n(20),
        .filename("pm.txt")
    ) pm_recorder_i(
    	.in(pm_out),
    	.en(1'b1),
    	.clk(record)
    );

    real_recorder #(
        .filename("delay.txt")
    ) delay_recorder_i(
    	.in(Tdelay),
    	.en(1'b1),
    	.clk(record)
    );

    task pulse_record();
        record = 1'b1;
        #0;
        record = 1'b0;
        #0;
    endtask

    task reset_pm();
        en_pm = 1'b0;
        #(10ns);
        en_pm = 1'b1;
        #(10ns);
    endtask

    // Main test logic

    real test_delays [n_tests];
    localparam real Twait = 1.1*(2.0**20-1)/(1.0*`CLK_REF_FREQ); // i.e., 10% higher than the minimum amount

    initial begin
        // initialization
        record = 1'b0;

        // generate test delays
        for (int i=0; i<n_tests; i=i+1) begin
            test_delays[i] = (1.0*i)/(1.0*n_tests*`CLK_REF_FREQ);
        end
        test_delays.shuffle();

        foreach (test_delays[i]) begin
            $display("Testing delay #%d/%d: %f ps", i+1, n_tests, 1e12*test_delays[i]);
            Tdelay = test_delays[i];
            reset_pm();
            #(Twait*1s);
            pulse_record();
        end
 
        #(1ns);
        $finish;
    end

endmodule

`default_nettype wire
