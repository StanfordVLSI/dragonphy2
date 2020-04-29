
module TDC_delay_unit_PR (input inv_in, input ff_in, input clk_phase_reverse, input pstb, output inv_out, output reg ff_out);

reg phase_reverse;

inv iinv(.in(inv_in), .out(inv_out));
x_nor ix_nor(.in1(inv_out), .in2(phase_reverse), .out(xnor_out));
ff_c ff_out_reg(.D(ff_in), .CP(xnor_out), .Q(ff_out));
ff_c_sn phase_reverse_reg(.D(ff_out), .CP(clk_phase_reverse), .Q(phase_reverse), .SDN(pstb));

endmodule


