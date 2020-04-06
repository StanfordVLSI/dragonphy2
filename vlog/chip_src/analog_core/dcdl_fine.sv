
module dcdl_fine #(parameter Nunit=4) ( out, ctl, disable_state, en, in );

input  disable_state, en, in;
input [$clog2(Nunit)-1:0]  ctl;
output  out;

wire enb;
wire [Nunit-1:0] mux_out;
wire  [Nunit-2:0]  ctl_thm;
	
assign enb = ~en;
assign ctl_thm = ~(('1 << ctl)&{(Nunit-1){en}});
assign out = mux_out[0];

mux imux_dont_touch[Nunit-1:0] (.in0(in), .in1({disable_state, mux_out[Nunit-1:1]}), .sel({enb, ctl_thm}), .out(mux_out));


endmodule


