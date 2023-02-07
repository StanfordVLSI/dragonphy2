`ifndef FUNC_DATA_WIDTH
    `define FUNC_DATA_WIDTH 18
`endif


`ifndef FUNC_NUMEL
    `define FUNC_NUMEL 2048
`endif

module test_analog_core import const_pack::*; #(
) (
    // Input bits
    input [(Nti-1):0] bits,

    // PI control bits
    input [Npi-1:0] ctl_pi_0,
    input [Npi-1:0] ctl_pi_1,
    input [Npi-1:0] ctl_pi_2,
    input [Npi-1:0] ctl_pi_3,

    // ADC magnitude outputs
    output [(Nadc-1):0] adder_out_0,
    output [(Nadc-1):0] adder_out_1,
    output [(Nadc-1):0] adder_out_2,
    output [(Nadc-1):0] adder_out_3,
    output [(Nadc-1):0] adder_out_4,
    output [(Nadc-1):0] adder_out_5,
    output [(Nadc-1):0] adder_out_6,
    output [(Nadc-1):0] adder_out_7,
    output [(Nadc-1):0] adder_out_8,
    output [(Nadc-1):0] adder_out_9,
    output [(Nadc-1):0] adder_out_10,
    output [(Nadc-1):0] adder_out_11,
    output [(Nadc-1):0] adder_out_12,
    output [(Nadc-1):0] adder_out_13,
    output [(Nadc-1):0] adder_out_14,
    output [(Nadc-1):0] adder_out_15,

    // ADC sign outputs
    output [(Nti-1):0] sign_out,

    // Emulator clock and reset
    input clk,
    input rst,

    // Jitter/Noise commands
    input [6:0] jitter_rms_int,
    input [10:0] noise_rms_int,

    // Step response control signals
    input [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_0,
    input [((`FUNC_DATA_WIDTH)-1):0] chan_wdata_1,
    input [($clog2(`FUNC_NUMEL))-1:0] chan_waddr,
    input chan_we
);
    // wire ctl_pi
    logic [Npi-1:0] ctl_pi [Nout-1:0];
    assign ctl_pi[0] = ctl_pi_0;
    assign ctl_pi[1] = ctl_pi_1;
    assign ctl_pi[2] = ctl_pi_2;
    assign ctl_pi[3] = ctl_pi_3;

    // wire adder_out (first output is not used but is X, which is
    // not handled by fault)
    logic [Nadc-1:0] adder_out [(Nti-1):0];
    assign adder_out_0  = (^adder_out[ 0]===1'bx) ? 0 : adder_out[ 0];
    assign adder_out_1  = (^adder_out[ 1]===1'bx) ? 0 : adder_out[ 1];
    assign adder_out_2  = (^adder_out[ 2]===1'bx) ? 0 : adder_out[ 2];
    assign adder_out_3  = (^adder_out[ 3]===1'bx) ? 0 : adder_out[ 3];
    assign adder_out_4  = (^adder_out[ 4]===1'bx) ? 0 : adder_out[ 4];
    assign adder_out_5  = (^adder_out[ 5]===1'bx) ? 0 : adder_out[ 5];
    assign adder_out_6  = (^adder_out[ 6]===1'bx) ? 0 : adder_out[ 6];
    assign adder_out_7  = (^adder_out[ 7]===1'bx) ? 0 : adder_out[ 7];
    assign adder_out_8  = (^adder_out[ 8]===1'bx) ? 0 : adder_out[ 8];
    assign adder_out_9  = (^adder_out[ 9]===1'bx) ? 0 : adder_out[ 9];
    assign adder_out_10 = (^adder_out[10]===1'bx) ? 0 : adder_out[10];
    assign adder_out_11 = (^adder_out[11]===1'bx) ? 0 : adder_out[11];
    assign adder_out_12 = (^adder_out[12]===1'bx) ? 0 : adder_out[12];
    assign adder_out_13 = (^adder_out[13]===1'bx) ? 0 : adder_out[13];
    assign adder_out_14 = (^adder_out[14]===1'bx) ? 0 : adder_out[14];
    assign adder_out_15 = (^adder_out[15]===1'bx) ? 0 : adder_out[15];

    // instantiate the debug interface (although it is unused)
    acore_debug_intf adbg_intf_i ();

    // instantiate the model
    analog_core analog_core_i (
        .rx_inp(bits),
        .ctl_pi(ctl_pi),
        .adder_out(adder_out),
        .sign_out(sign_out),
        .adbg_intf_i(adbg_intf_i),

        // unused I/O
        // explicitly indicated to prevent noisy warnings
        .clk_adc(),
        .adder_out_rep(),
        .sign_out_rep(),
        .rx_inn(),
        .Vcm(),
        .rx_inp_test(),
        .rx_inn_test(),
        .ext_clk(),
        .mdll_clk(),
        .ext_clk_test0(),
        .ext_clk_test1(),
        .clk_async(),
        .ctl_valid(),
        .Vcal()
    );

    // wire emulator control signals through the hierarchy
    assign analog_core_i.emu_clk = clk;
    assign analog_core_i.emu_rst = rst;
    assign analog_core_i.jitter_rms_int = jitter_rms_int;
    assign analog_core_i.noise_rms_int = noise_rms_int;
    assign analog_core_i.chan_wdata_0 = chan_wdata_0;
    assign analog_core_i.chan_wdata_1 = chan_wdata_1;
    assign analog_core_i.chan_waddr = chan_waddr;
    assign analog_core_i.chan_we = chan_we;

    // waveform dumping
    initial begin
        `ifdef DUMP_WAVEFORMS
	        $shm_open("waves.shm");
	        $shm_probe("ASMC");
        `endif
    end
endmodule
