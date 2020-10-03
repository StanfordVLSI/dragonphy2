`default_nettype none

module histogram_core #(
    parameter integer n_data=8,
    parameter integer n_count=64
) (
    // basic clock for this block
    input wire logic clk,

    // SRAM chip enable (should typically be "0")
    input wire logic ceb,

    // operating mode
    // 2'b00: INCR_RD
    // 2'b01: INCR_WR
    // 2'b10:  CLR_WR
    // 2'b11:  EXT_RD
    input wire logic [1:0] mode,

    // input addresses
    input wire logic [(n_data-1):0] addr_clr,
    input wire logic [(n_data-1):0] addr_ext,
    input wire logic [(n_data-1):0] addr_new,
    input wire logic [(n_data-1):0] addr_old,

    // output value
    output wire logic [(n_count-1):0] out
);
    ////////////////////
    // operating mode //
    ////////////////////

    localparam logic [1:0] INCR_RD = 2'b00;
    localparam logic [1:0] INCR_WR = 2'b01;
    localparam logic [1:0]  CLR_WR = 2'b10;
    localparam logic [1:0]  EXT_RD = 2'b11;

    //////////////////////
    // instantiate SRAM //
    //////////////////////

    logic WEB;
    logic [(n_data-1):0] A;
    logic [(n_count-1):0] D;
    logic [(n_count-1):0] Q;

    sram_small #(
        .ADR_BITS(n_data),
        .DAT_BITS(n_count)
    ) hist_sram_inst (
	    .CLK(clk),
	    .CEB(ceb),
	    .WEB(WEB),
	    .A(A),
	    .D(D),
	    .Q(Q)
	);

    ////////////////
    // main logic //
    ////////////////

    // data computation

    assign D = (mode == CLR_WR) ? 0 : (1 + Q);

    // write enable

    always @(*) begin
        case (mode)
            INCR_RD: WEB = 1'b1;
            INCR_WR: WEB = 1'b0;
             CLR_WR: WEB = 1'b0;
             EXT_RD: WEB = 1'b1;
            default: A = 1'bx;
        endcase
    end

    // address selection

    always @(*) begin
        case (mode)
            INCR_RD: A = addr_new;
            INCR_WR: A = addr_old;
             CLR_WR: A = addr_clr;
             EXT_RD: A = addr_ext;
            default: A = 'x;
        endcase
    end

    ////////////////////
    // assign outputs //
    ////////////////////

    assign out = Q;

endmodule

`default_nettype wire
