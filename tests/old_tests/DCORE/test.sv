`include "mLingua_pwl.vh"

`default_nettype none

module test;
	import const_pack::*;
	import test_pack::*;

	logic ext_clkp;
	logic ext_clkn;

	clock #(
		.freq(full_rate/2),
		.duty(0.5),
		.td(0)
	) iEXTCLK (
		.ckout(ext_clkp),
		.ckoutb(ext_clkn)
	);

    acore_debug_intf ad_intf_i();
    jtag_intf jtag_intf_i();

	digital_core idcore(
	    .adbg_intf_i(ad_intf_i),
	    .jtag_intf_i(jtag_intf_i)
	);

	initial begin
	    #(100ns);
	    $finish;
	    $display("Success!");
	end
endmodule

`default_nettype wire
