`ifndef __IOTYPE_SV__
`define __IOTYPE_SV__

    `include "svreal.sv"

    // analog representation
    // resolution is about 0.2 mV
    // range is about +/- 30 V

    `define PWL_WIDTH 18
    `define PWL_EXPONENT -12
    `define PWL_RANGE 30.0
    `define pwl_t wire logic signed [((`PWL_WIDTH)-1):0]

    `define DECL_PWL(name) \
        `REAL_FROM_WIDTH_EXP(``name``, `PWL_WIDTH, `PWL_EXPONENT)
    `define DECL_DT(name) \
        `REAL_FROM_WIDTH_EXP(``name``, `DT_WIDTH, `DT_EXPONENT)

    `define ATTACH_PWL_PARAMS(name) \
        localparam real `RANGE_PARAM_REAL(``name``) = `PWL_RANGE; \
        localparam integer `WIDTH_PARAM_REAL(``name``) = `PWL_WIDTH; \
        localparam integer `EXPONENT_PARAM_REAL(``name``) = `PWL_EXPONENT \

	// not implemented yet
	`define real_t wire logic
	`define voltage_t wire logic

	`define PWL_ZERO 1'b0

`endif // `ifndef __IOTYPE_SV__
