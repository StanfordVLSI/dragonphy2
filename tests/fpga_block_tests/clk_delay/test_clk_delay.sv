`include "svreal.sv"

module test_clk_delay (
    input wire logic [8:0] code,
    input wire logic clk_i_val,
    output wire logic clk_o_val,
    input real dt_req,
    output real emu_dt,
    input [31:0] jitter_seed,
    input real jitter_rms,
    input wire logic emu_clk,
    input wire logic emu_rst
);
    // jitter control
    `MAKE_REAL(jitter_rms_int, 10e-12);
    assign `FORCE_REAL(jitter_rms, jitter_rms_int);

    // format for timesteps
    `REAL_FROM_WIDTH_EXP(emu_dt_int, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_ext, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_dly, `DT_WIDTH, `DT_EXPONENT);

    // wire to external real values
    assign `FORCE_REAL(dt_req, dt_req_ext);
    assign emu_dt = `TO_REAL(emu_dt_int);

    // monitor the time delay requested by the delay block
    real dt_req_dly_real;
    assign dt_req_dly_real = `TO_REAL(dt_req_dly);

    // implement basic timestep management
    `MIN_INTO_REAL(dt_req_ext, dt_req_dly, emu_dt_int);

    // set maximum value for timestep
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    `ASSIGN_CONST_REAL(((2.0**((`DT_WIDTH)-1))-1.0)*2.0**(`DT_EXPONENT), dt_req_max);

    // instantiate MSDSL model, passing through format information
    clk_delay_core #(
        `PASS_REAL(emu_dt, emu_dt_int),
        `PASS_REAL(dt_req, dt_req_dly),
        `PASS_REAL(dt_req_max, dt_req_max),
        `PASS_REAL(jitter_rms, jitter_rms_int)
    ) clk_delay_core_i (
        // main I/O: delay code, clock in/out values
        .code(code),
        .clk_i_val(clk_i_val),
        .clk_o_val(clk_o_val),

        // timestep control: DT request and response
        .dt_req(dt_req_dly),
        .emu_dt(emu_dt_int),

        // jitter control
	.jitter_seed(jitter_seed),
        .jitter_rms(jitter_rms_int),

        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),

        // additional input: maximum timestep
        .dt_req_max(dt_req_max)
    );
endmodule
