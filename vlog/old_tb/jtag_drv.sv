`default_nettype none

module jtag_drv #(
) (
	jtag_intf.host jtag_intf_i
);

	// clock

	logic jtag_clk;

	clock #(
		.freq(1e9),
		.duty(0.5),
		.td(0)
	) clock_i (
		.ckout(jtag_clk)
	);

	// import all names from the JTAG driver package
	import jtag_drv_pack::*;
	
	// JTAG interface used by lower-level JTAG driver
	raw_jtag_ifc_unq1 ifc (.Clk(jtag_clk));

	// Instantiate lower-level JTAG driver
	JTAGDriver jdrv = new(ifc);

	// Wire up the two interfaces 
	assign jtag_intf_i.phy_tdi = ifc.tdi;
	assign ifc.tdo = jtag_intf_i.phy_tdo;
	assign jtag_intf_i.phy_tck = ifc.tck;
	assign jtag_intf_i.phy_tms = ifc.tms;
	assign jtag_intf_i.phy_trst_n = ifc.trst_n;

	task init();
		// move the JTAG controller to a known state
		jdrv.Zero();
		jdrv.Reset();

		// delay a bit
		repeat (10) @(posedge ifc.Clk);
	endtask

	task read_id(output [31:0] data);
		jtag_regfile_trans_t jtag_trans;

		// send the read ID request
		jdrv.ReadID(jtag_trans);

		// get the data back
		jtag_trans = jdrv.GetResult();

		// return data
		data = jtag_trans.data_out;

		// delay a clock cycle
		@(posedge ifc.Clk);
	endtask

	task write_tc_reg(input [13:0] addr, input [31:0] data);
		write_reg(tc_domain, addr, data);
	endtask

	task write_sc_reg(input [13:0] addr, input [31:0] data);
		write_reg(sc_domain, addr, data);
	endtask

	task write_reg(input regfile_t clk_domain, input [13:0] addr, input [31:0] data);
		jtag_regfile_trans_t jtag_trans;

		// set up the transaction
		jtag_trans.domain = clk_domain;
		jtag_trans.addr = addr;				// First register in the DP block
		jtag_trans.op = write;
		jtag_trans.data_out = 'h0;
		jtag_trans.data_in = data;
		jtag_trans.done = 0;

		// send the request
		jdrv.Send(jtag_trans);

		// delay a clock cycle
		@(posedge ifc.Clk);
	endtask

	task read_tc_reg(input [14:0] addr, output [31:0] data);
		read_reg(tc_domain, addr, data);
	endtask

	task read_sc_reg(input [14:0] addr, output [31:0] data);
		read_reg(sc_domain, addr, data);
	endtask

	task read_reg(input regfile_t clk_domain, input [14:0] addr, output [31:0] data);
		jtag_regfile_trans_t jtag_trans;

		// set up the transaction
		jtag_trans.domain = clk_domain;
		jtag_trans.addr = addr;				// First register in the DP block
		jtag_trans.op = read;
		jtag_trans.data_out = 'h0;
		jtag_trans.data_in = 'hABCD;		//we don't really care data_in, since it is a read op
		jtag_trans.done = 0;

		// send the read request
		jdrv.Send(jtag_trans);

		// get the data back
		jtag_trans = jdrv.GetResult();
		@(posedge ifc.Clk);
		// return data
		data = jtag_trans.data_out;

		// delay a clock cycle
		@(posedge ifc.Clk);
	endtask

endmodule

`default_nettype wire
