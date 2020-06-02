`default_nettype none

interface jtag_intf;

	logic phy_tdi;
	logic phy_tdo;
	logic phy_tck;
	logic phy_tms;
	logic phy_trst_n;

	modport host (
		output phy_tdi,
		input  phy_tdo,
		output phy_tck,
		output phy_tms,
		output phy_trst_n
	);

	modport target (
		input  phy_tdi,
		output phy_tdo,
		input  phy_tck,
		input  phy_tms,
		input  phy_trst_n
	);

endinterface

`default_nettype wire
