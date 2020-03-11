`include "svreal.sv"
`include "signals.sv"

module rx_adc #(
    parameter real v_ref_p=+1.0,
    parameter real v_ref_n=-1.0,
    parameter integer n_adc=8
) (
    `ANALOG_INPUT in,
    output wire logic signed [(n_adc-1):0] out,
    input wire logic clk,
    // TODO: figure out a cleaner way to pass clk_o_val
    input wire logic clk_val,
    input wire logic rst
);
    // signals use for external I/O
    (* dont_touch = "true" *) logic __emu_rst;
    (* dont_touch = "true" *) logic __emu_clk;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;

    generate
        logic emu_stall;
        rx_adc_core #(
            `INTF_PASS_REAL(in_, in.value)
        ) rx_adc_core_i (
            .in_(in.value),
            .out(out),
            .clk_val(clk_val),
            // emulator control signal
            .emu_clk(__emu_clk),
            .emu_rst(__emu_rst),
            .emu_stall(emu_stall)
        );
        assign __emu_dt_req = emu_stall ? 0 : {((`DT_WIDTH)-1){1'b1}};
    endgenerate   
endmodule
