`ifndef __IOTYPE_SV__
`define __IOTYPE_SV__

    `include "svreal.sv"

    // analog representation
    // resolution is about 0.2 mV
    // range is about +/- 30 V

    `define PWL_WIDTH 18
    `define PWL_EXPONENT -12
    `define pwl_t wire logic signed [((`PWL_WIDTH)-1):0]

	// not implemented yet
	`define real_t wire logic
	`define voltage_t wire logic

	`define PWL_ZERO 1'b0

`endif // `ifndef __IOTYPE_SV__
