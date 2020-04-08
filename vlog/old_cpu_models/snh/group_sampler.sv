/********************************************************************
filename: group_sampler.sv

Description:
Behavioal model of 2nd-level S&H circuit

Assumptions:

Todo:
    - This needs to be moved to ti_ti_stochastic_adc_func
    - Local clock generation is not implemented.

********************************************************************/
`include "mLingua_pwl.vh"

`default_nettype none

module group_sampler import const_pack::*; #(
	parameter integer Nsub = Nti/Nout   // # of S&Hs at the 2nd level
) (
	input pwl in_p, // (+) input
    input pwl in_n, // (-) input
    output real out_p [Nsub-1:0],   // (+) sampled output
    output real out_n [Nsub-1:0],   // (-) sampled output
    input wire logic clk            // sampling clock
);

`get_timeunit
PWLMethod pm=new;

shortint idx;   // index of the current operating S&H circuit 

initial idx = -1;

always @(negedge clk) 
begin
	out_p[idx] = pm.eval(in_p, `get_time);
	out_n[idx] = pm.eval(in_n, `get_time);

    idx = (idx+1) % Nsub;
end

endmodule

`default_nettype wire
