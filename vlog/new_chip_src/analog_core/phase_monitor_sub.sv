
module phase_monitor_sub(
    input ph_ref,
    input ph_in,
    input en_sync,
    input clk_async,
    input [1:0] sel_sign,
    output reg ff_in,
    output reg ff_ref,
    output xor_ref_bf
);

wire net_x;

// synopsys dc_script_begin
// set_dont_touch {ph* sel* xor*}
// synopsys dc_script_end

x_or uXOR0 (.in1(ph_in), .in2(sel_sign[0]), .out(xor_in));
x_or uXOR1 (.in1(ph_ref), .in2(sel_sign[1]), .out(xor_ref));

inv iin_buff_dmm0  (.in(xor_in), .out(xor_in_buff));
inv iin_buff_dmm1  (.in(xor_in_buff), .out(net_x));
inv iref_buff0 (.in(xor_ref), .out(xor_ref_buff));
inv iref_buff1 (.in(xor_ref_buff), .out(xor_ref_bf));

ff_c_rn ff_in_reg(.D(clk_async), .CP(xor_in), .Q(ff_in), .CDN(en_sync));
ff_c_rn ff_ref_reg(.D(clk_async), .CP(xor_ref), .Q(ff_ref), .CDN(en_sync));


endmodule



