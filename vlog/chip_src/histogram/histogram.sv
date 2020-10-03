`default_nettype none

module histogram #(
    parameter integer n_data=8,
    parameter integer n_count=64
) (
    // basic clock for this block
    input wire logic clk,

    // SRAM chip enable (should typically be "0")
    input wire logic sram_ceb,

    // operating mode
    // 3'b000: RESET
    // 3'b001: CLEAR
    // 3'b010: RUN
    // 3'b011: FREEZE
    // 3'b100 and up: HOLD
    input wire logic [2:0] mode,

    // input data
    input wire logic [(n_data-1):0] data,

    // input address
    input wire logic [(n_data-1):0] addr,

    // output count
    output wire logic [(n_count-1):0] count,

    // output total
    output wire logic [(n_count-1):0] total
);
    /////////////////////
    // operating modes //
    /////////////////////

    localparam logic [2:0]  RESET = 3'b000;
    localparam logic [2:0]  CLEAR = 3'b001;
    localparam logic [2:0]    RUN = 3'b010;
    localparam logic [2:0] FREEZE = 3'b011;
    // 3'b100 and up: HOLD

    ///////////////////////
    // address selection //
    ///////////////////////

    localparam logic [1:0] INCR_RD = 2'b00;
    localparam logic [1:0] INCR_WR = 2'b01;
    localparam logic [1:0]  CLR_WR = 2'b10;
    localparam logic [1:0]  EXT_RD = 2'b11;

    //////////////////////////////
    // internal state variables //
    //////////////////////////////

    // SRAM modes
    logic [1:0] sram_mode_0;
    logic [1:0] sram_mode_1;

    // other
    logic [(n_count-1):0] total_reg;
    logic [(n_data-1):0] addr_clr;

    ///////////////////
    // register data //
    ///////////////////

    logic [(n_data-1):0] data_new;
    logic [(n_data-1):0] data_old;

    always @(posedge clk) begin
        data_new <= data;
        data_old <= data_new;
    end

    //////////////////////
    // register address //
    //////////////////////

    logic [(n_data-1):0] addr_ext;

    always @(posedge clk) begin
        addr_ext <= addr;
    end

    ////////////////////////
    // main state machine //
    ////////////////////////

    always @(posedge clk) begin
        if (mode == RESET) begin
            sram_mode_0 <= CLR_WR;
            sram_mode_1 <= CLR_WR;
            total_reg <= 0;
            addr_clr <= 0;
        end else if (mode == CLEAR) begin
            if (addr_clr == {n_data{1'b1}}) begin
                sram_mode_0 <= INCR_RD;
                sram_mode_1 <= INCR_RD;
                addr_clr <= addr_clr;
            end else begin
                sram_mode_0 <= CLR_WR;
                sram_mode_1 <= CLR_WR;
                addr_clr <= addr_clr + 1;
            end

            // other
            total_reg <= 0;
        end else if (mode == RUN) begin
            if (sram_mode_0 == INCR_RD) begin
                sram_mode_0 <= INCR_WR;
                sram_mode_1 <= INCR_RD;
            end else begin
                sram_mode_0 <= INCR_RD;
                sram_mode_1 <= INCR_WR;
            end

            // other
            total_reg <= total_reg + 1;
            addr_clr <= 0;
        end else if (mode == FREEZE) begin
            sram_mode_0 <= EXT_RD;
            sram_mode_1 <= EXT_RD;
            total_reg <= total_reg;
            addr_clr <= 0;
        end else begin
            sram_mode_0 <= sram_mode_0;
            sram_mode_1 <= sram_mode_1;
            total_reg <= total_reg;
            addr_clr <= addr_clr;
        end
    end

    ///////////////////////
    // instantiate cores //
    ///////////////////////

    // Core 0

    logic [(n_count-1):0] q0;

    histogram_core #(
        .n_data(n_data),
        .n_count(n_count)
    ) core_0 (
        .clk(clk),
        .ceb(sram_ceb),
        .mode(sram_mode_0),
        .addr_clr(addr_clr),
        .addr_ext(addr_ext),
        .addr_new(data_new),
        .addr_old(data_old),
        .out(q0)
    );

    // Core 1

    logic [(n_count-1):0] q1;

    histogram_core #(
        .n_data(n_data),
        .n_count(n_count)
    ) core_1 (
        .clk(clk),
        .ceb(sram_ceb),
        .mode(sram_mode_1),
        .addr_clr(addr_clr),
        .addr_ext(addr_ext),
        .addr_new(data_new),
        .addr_old(data_old),
        .out(q1)
    );

    ////////////////////////////
    // sum partial histograms //
    ////////////////////////////

    logic [(n_count-1):0] q0_reg;
    logic [(n_count-1):0] q1_reg;
    logic [(n_count-1):0] count_reg;

    always @(posedge clk) begin
        q0_reg <= q0;
        q1_reg <= q1;
        count_reg <= q0_reg + q1_reg;
    end

    ////////////////////
    // assign outputs //
    ////////////////////

    assign count = count_reg;
    assign total = total_reg;

endmodule

`default_nettype wire