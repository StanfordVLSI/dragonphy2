// dragon uses tb

`include "svreal.sv"

module gen_emu_clks #(
    parameter integer n=2
) (
    input wire logic emu_clk_2x,
    output wire logic emu_clk,
    input wire logic clk_vals [n],
    output wire logic clks [n]
);

    // generate emu_clk
    logic emu_clk_unbuf = 0;
    always @(posedge emu_clk_2x) begin
        emu_clk_unbuf <= ~emu_clk_unbuf;
    end
    assign emu_clk = emu_clk_unbuf;

    // generate other clocks
    logic clk_unbufs [n];
    generate
        for (genvar k=0; k<n; k=k+1) begin : gen_other
            always @(posedge emu_clk_2x) begin
                if (emu_clk_unbuf == 1'b0) begin
                    clk_unbufs[k] <= clk_vals[k];
                end else begin
                    clk_unbufs[k] <= clk_unbufs[k];
                end
            end
            assign clks[k] = clk_unbufs[k];
        end
    endgenerate
endmodule

module stim;
    // instantiate the testbench
    tb tb_i ();

    // generate emu_clk_2x
    localparam real emu_clk_2x_freq = 20e6;
    logic emu_clk_2x;
    always begin
        emu_clk_2x = 1'b0;
        #((0.5/emu_clk_2x_freq)*1s);
        emu_clk_2x = 1'b1;
        #((0.5/emu_clk_2x_freq)*1s);
    end

    // handle timestep requests
    logic signed [((`DT_WIDTH)-1):0] emu_dt;
    assign emu_dt = `SVREAL_EXPR_MIN(tb_i.rx_i.rx_clk_i.__emu_dt_req, tb_i.tx_clk_i.__emu_dt_req);
    assign tb_i.rx_i.rx_clk_i.__emu_dt = emu_dt;
    assign tb_i.tx_clk_i.__emu_dt = emu_dt;
    
    // rst_user
    logic rst_user;
    assign tb_i.rst_user = rst_user;

    // number
    logic [63:0] number;
    assign number = tb_i.number;

    // emu_rst
    logic emu_rst;
    assign tb_i.rx_i.rx_clk_i.__emu_rst = emu_rst;
    assign tb_i.tx_clk_i.__emu_rst = emu_rst;

    // clock value wiring
    logic clk_vals[2];
    assign clk_vals[0] = tb_i.rx_i.rx_clk_i.__emu_clk_val;
    assign clk_vals[1] = tb_i.tx_clk_i.__emu_clk_val;

    // clock wiring
    logic clks[2];
    assign tb_i.rx_i.rx_clk_i.__emu_clk_i = clks[0];
    assign tb_i.tx_clk_i.__emu_clk_i = clks[1];

    // emu_clk wiring
    logic emu_clk;
    assign tb_i.tx_clk_i.__emu_clk = emu_clk;
    assign tb_i.rx_i.rx_clk_i.__emu_clk = emu_clk;

    // instantiate the clock manager
    gen_emu_clks #(
        .n(2)
    ) gen_emu_clks_i (
        .emu_clk_2x(emu_clk_2x),
        .emu_clk(emu_clk),
        .clk_vals(clk_vals),
        .clks(clks)
    );

    // generate the test vector
    initial begin
        emu_rst = 1'b1;
        rst_user = 1'b1;
        #(3us);
        emu_rst = 1'b0;
        #(3us);
        rst_user = 1'b0; 
        #(100us);
        assert (number >= 400) else
            $error("Not enough successful bits.");
        $finish;
    end
endmodule
