
module TDC_delay_chain_PR #(parameter Nunit=255) (
input en_phase_reverse,
input logic clk, 
input logic Tin,
input clk_phase_reverse, 
output logic del_out, 
output reg [Nunit-1:0] ff_out 
);

logic [Nunit-1:0] inv_out;
assign del_out = inv_out[Nunit-1];
// synopsys dc_script_begin
// set_dont_touch {inv_out*}
// synopsys dc_script_end

TDC_delay_unit_PR iTDC_delay_unit[Nunit-1:0] (.inv_in({inv_out[Nunit-2:0], clk}), .pstb(en_phase_reverse), .clk_phase_reverse(clk_phase_reverse), .ff_in(Tin), .inv_out(inv_out), .ff_out(ff_out)); 

endmodule


