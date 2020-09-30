`timescale 1fs/1fs

`ifndef CLK_REF_FREQ
    `define CLK_REF_FREQ 4e9
`endif

module test (
    input en_mixer,
    input real delay0,
    input real delay1,
    output real delay_out,
    output real freq_out,
    output real duty_out
);
    // generate main reference clock
    logic ph_ref;
    clock #(
        .freq(`CLK_REF_FREQ),
        .duty(0.5),
        .td(0)
    ) i_ph_ref (
        .ckout(ph_ref),
        .ckoutb()
    );

    // delay ph_in signals with respect to the reference clock
    logic [1:0] ph_in;
    always @(ph_ref) begin
        ph_in[0] <= #(delay0*1s) ph_ref;
        ph_in[1] <= #(delay1*1s) ph_ref;
    end

    // instantiate the phase blender
    logic ph_out;
    phase_blender_1b pb_i (
        .ph_in(ph_in),
        .en_mixer(en_mixer),
        .ph_out(ph_out)
    );

    // measure the delay of the output phase
    real delay_out_imm;
    delay_meas_ideal idmeas (
        .ref_in(ph_ref),
        .in(ph_out),
        .delay(delay_out_imm)
    );
    assign delay_out = 1e12*delay_out_imm;

    // measure the frequency and duty cycle of the output phase

	real rising_edge_time=-1;
	real falling_edge_time=-1;

	always @(posedge ph_out) begin
        if (rising_edge_time != -1) begin
            freq_out = 1e-9/(($realtime/1s)-rising_edge_time);
            if (falling_edge_time != -1) begin
                duty_out = (falling_edge_time-rising_edge_time)/(($realtime/1s)-rising_edge_time);
            end
        end
        rising_edge_time=$realtime/1s;
    end

    always @(negedge ph_out) begin
        falling_edge_time = $realtime/1s;
    end
endmodule
