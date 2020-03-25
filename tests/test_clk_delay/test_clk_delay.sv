`include "svreal.sv"

module test_clk_delay (
    input wire logic [7:0] code,
    input wire logic clk_i_val,
    output wire logic clk_o_val,
    input real dt_req,
    output real emu_dt,
    input wire logic emu_clk,
    input wire logic emu_rst
);
    // format for timesteps
    `REAL_FROM_WIDTH_EXP(emu_dt_int, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_ext, `DT_WIDTH, `DT_EXPONENT);
    `REAL_FROM_WIDTH_EXP(dt_req_dly, `DT_WIDTH, `DT_EXPONENT);

    // wire to external real values
    assign `FORCE_REAL(dt_req, dt_req_ext);
    assign emu_dt = `TO_REAL(emu_dt_int);

    // monitor the time delay requested by the delay block
    real dt_req_dly_real;
    assign dt_req_dly_real = `TO_REAL(dt_req_dly    );

    // implement basic timestep management
    `MIN_INTO_REAL(dt_req_ext, dt_req_dly, emu_dt_int);

    // set maximum value for timestep
    // TODO: clean this up because it is not compatible with the `FLOAT_REAL option
    `REAL_FROM_WIDTH_EXP(dt_req_max, `DT_WIDTH, `DT_EXPONENT);
    assign dt_req_max = {1'b0, {((`DT_WIDTH)-1){1'b1}}};

    // instantiate MSDSL model, passing through format information
    clk_delay_core #(
        `PASS_REAL(emu_dt, emu_dt_int),
        `PASS_REAL(dt_req, dt_req_ext),
        `PASS_REAL(dt_req_max, dt_req_max)
    ) clk_delay_core_i (
        // main I/O: delay code, clock in/out values
        .code(code),
        .clk_i_val(clk_i_val),
        .clk_o_val(clk_o_val),
        // timestep control: DT request and response
        .dt_req(dt_req_dly),
        .emu_dt(emu_dt_int),
        // emulator clock and reset
        .emu_clk(emu_clk),
        .emu_rst(emu_rst),
        // additional input: maximum timestep
        // TODO: clean this up because it is not compatible with the `FLOAT_REAL option
        .dt_req_max(dt_req_max)
    );
endmodule