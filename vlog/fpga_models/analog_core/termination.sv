`include "iotype.sv"

module termination (
	input `pwl_t VinP,
	input `pwl_t VinN,
	input `real_t Vcm
);

    // needed to convince Vivado this is not a black box
    `pwl_t dummy;
    assign dummy = VinP;

endmodule