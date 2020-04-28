module inv_chain #(
    parameter Ninv=8
) (
    input logic in,
    output logic out
);
//synopsys dc_script_begin
// set_dont_touch {inv_out*}
//synopsys dc_script_end


    logic [Ninv-2:0] inv_out;

    inv iinv [Ninv-1:0] (
        .in({inv_out, in}),
        .out({out, inv_out})
    );

endmodule


