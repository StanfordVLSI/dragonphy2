`include "iotype.sv"

module input_divider (
    input wire logic in,
    input wire logic in_mdll,
    input wire logic sel_clk_source,
    input wire logic en,
    input wire logic en_meas,
    input wire logic [2:0] ndiv,
    input wire logic bypass_div,
    input wire logic bypass_div2,
    output wire logic out,
    output wire logic out_meas
);

    // signals use for external I/O
    (* dont_touch = "true" *) logic emu_rst;
    (* dont_touch = "true" *) logic emu_clk;

    // detect edge on input clock
    my_edgedet det_i (
        .val(in),
        .clk(emu_clk),
        .rst(emu_rst),
        .edge_p(posedge_in),
        .edge_n()
    );

    // simplified model of original circuit: divide clock by two
    logic div_state;
   
    assign out = posedge_in ? ~div_state : div_state;

    always @(posedge emu_clk) begin
        if (emu_rst == 1'b1) begin
            div_state <= 1'b0;
        end else if (posedge_in) begin
            div_state <= ~div_state;
        end else begin
            div_state <= div_state;
        end
    end

    // out_meas is unused
    assign out_meas = 1'b0;
endmodule
