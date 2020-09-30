module PI_delay_chain #(
parameter Nunit = 32
)(
//synopsys dc_script_begin
//set_dont_touch {clk_in}
//synopsys dc_script_end

input clk_in, 
input en_arb, 
input [Nunit-1:0] en_mixer,
input [Nunit-1:0] inc_del,

output [Nunit-1:0] mclk_out,
output [Nunit-1:0] arb_out,
output del_out
);

wire  [Nunit-2:0]  chain_out;

PI_delay_unit  iPI_delay_unit_dont_touch[Nunit-1:0] ( .arb_out(arb_out), .buf_out(mclk_out), .chain_out({del_out, chain_out}), .arb_in(clk_in), .chain_in({chain_out, clk_in}), .inc_del(inc_del), .en_arb(en_arb), .en_mixer(en_mixer));

endmodule

