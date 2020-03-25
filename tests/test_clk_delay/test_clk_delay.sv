`include "svreal.sv"

module test_clk_delay (
    input wire logic [7:0] code,
    input wire logic emu_clk,
    input wire logic emu_rst
);
    // format for timesteps
    `REAL_FROM_WIDTH_EXP(emu_dt, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_dly, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_clk, `DT_WIDTH, `DT_EXPONENT);

    // monitor the time delay requested by the delay and oscillator blocks
    real dt_req_dly_real, dt_req_clk_real, emu_dt_real;
    assign dt_req_dly_real = `TO_REAL(dt_req_dly);
    assign dt_req_clk_real = `TO_REAL(dt_req_clk);
    assign emu_dt_real = `TO_REAL(emu_dt);

    // implement basic timestep management
    `MIN_INTO_REAL(dt_req_dly, dt_req_clk, emu_dt);

    // set maximum value for timestep
    // TODO: clean this up because it is not compatible with the `FLOAT_REAL option
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    assign dt_req_max = {1'b0, {((`DT_WIDTH)-1){1'b1}}};

    // instantiate MSDSL model, passing through format information
    logic clk_i_val;
    clk_delay_core #(
        `PASS_REAL(emu_dt, emu_dt),
        `PASS_REAL(dt_req, dt_req_dly),
        `PASS_REAL(dt_req_max, dt_req_max)
    ) clk_delay_core_i (
        // main I/O: delay code, clock in/out values
        .code(code),
        .clk_i_val(clk_i_val),
        .clk_o_val(clk_o_val),
        // timestep control: DT request and response
        .dt_req(dt_req_dly),
        .emu_dt(emu_dt),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // additional input: maximum timestep
        // TODO: clean this up because it is not compatible with the `FLOAT_REAL option
        .dt_req_max(dt_req_max)
    );

    // instantiate MSDSL model, passing through format information
    osc_model_core #(
        `PASS_REAL(emu_dt, emu_dt),
        `PASS_REAL(dt_req, dt_req_clk)
    ) osc_model_core_i (
        // main output
        .clk_val(clk_i_val),
        // timestep control: DT request and response
        .dt_req(dt_req_clk),
        .emu_dt(emu_dt),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // unused
        .clk_i(1'b0),
        .clk_o()
    );
endmodule