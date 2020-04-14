/********************************************************************
filename: TDC_delay_unit.sv

Description:
Unit cell of a TDC delay chain + F/F

Assumptions:

Todo:
    - Model metastability of a F/F

********************************************************************/

module TDC_delay_unit_PR (
    input inv_in,
    output reg inv_out,
    output xnor_out,
    input ff_in,
    output reg ff_out,
    input clk_phase_reverse,
    input pstb
);

    import model_pack::*;

    // design parameter class instantiation

    TDCParameter tdc_obj;

    // variables

    real td0_inv;    // inverter delay w/o jitter
    real rj;         // random jitter
    real td_ff;      // clk-q delay of a F/F

    // initialize class parameters
    initial begin
        tdc_obj = new();
        td0_inv = tdc_obj.td_inv;
        td_ff = tdc_obj.td_ff_ck_q;
    end

    ///////////////////////////
    // Model Body
    ///////////////////////////

    logic phase_reverse;

    // inverter
    always @(inv_in) begin
        rj = tdc_obj.get_rj();
        inv_out <= #((td0_inv+rj)*1s) ~inv_in;
    end

    // XNOR gate
    // TODO: randomize
    assign xnor_out = ~(inv_out^phase_reverse);

    // Updating phase_reverse signal
    always @(posedge clk_phase_reverse or negedge pstb) begin
        if (!pstb) begin
            phase_reverse <= 1'b1;
        end else begin
            phase_reverse <= ff_out;
        end
    end

    // Main flip flop
    always_ff @(posedge inv_out) begin
        ff_out <= #(td_ff*1s) ff_in;
    end
endmodule