`default_nettype none

module histogram_data_gen #(
    parameter integer n=8
) (
    // basic clock for this block
    input wire logic clk,

    // define the operating mode
    // 3'b000: RESET
    // 3'b001: UNIFORM
    // 3'b010: CONSTANT
    // 3'b011: INCL
    // 3'b100: EXCL
    // 3'b101: ALT
    // 3'b110 and up: HOLD
    input wire logic [2:0] mode,

    // input data
    input wire logic [(n-1):0] in0,
    input wire logic [(n-1):0] in1,

    // output data
    input wire logic [(n-1):0] out
);
    /////////////////////
    // operating modes //
    /////////////////////

    localparam logic [2:0]    RESET = 3'b000;
    localparam logic [2:0]  UNIFORM = 3'b001;
    localparam logic [2:0] CONSTANT = 3'b010;
    localparam logic [2:0]     INCL = 3'b011;
    localparam logic [2:0]     EXCL = 3'b100;
    localparam logic [2:0]      ALT = 3'b101;
    // 3'b110 and up: HOLD

    //////////////////////////////
    // internal state variables //
    //////////////////////////////

    logic [(n-1):0] state;
    logic [(n-1):0] in0_reg;
    logic [(n-1):0] in1_reg;

    /////////////////////
    // register inputs //
    /////////////////////

    always @(posedge clk) begin
        in0_reg <= in0;
        in1_reg <= in1;
    end

    ////////////////////////
    // main state machine //
    ////////////////////////

    always @(posedge clk) begin
        if (mode == RESET) begin
            state <= 0;
        end else if (mode == UNIFORM) begin
            // produce a uniform distribution
            state <= state + 1;
        end else if (mode == CONSTANT) begin
            // produce a single value as output
            state <= in0_reg;
        end else if (mode == INCL) begin
            // produce values in range [in0, in1]
            if ((in0_reg <= (state + 1)) && ((state + 1) <= in1_reg)) begin
                state <= state + 1;
            end else begin
                state <= in0_reg;
            end
        end else if (mode == EXCL) begin
            // produce values in range [0, in0) U (in1, 2**n - 1]
            if (((state + 1) < in0_reg) || (in1_reg < (state + 1))) begin
                state <= state + 1;
            end else begin
                state <= in1_reg+1;
            end
        end else if (mode == ALT) begin
            // alternate between in0 and in1
            if (state == in0_reg) begin
                state <= in1_reg;
            end else begin
                state <= in0_reg;
            end
        end else begin
            // hold previous state (i.e., clock disabled)
            state <= state;
        end
    end

    ////////////////////
    // assign outputs //
    ////////////////////

    assign out = state;
endmodule

`default_nettype wire