
`include "mdll_pkg.sv"

`ifdef SIMULATION
    `define ANALOG_WIRE real
`else
    `define ANALOG_WIRE wire
`endif

