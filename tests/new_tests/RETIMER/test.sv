`include "mLingua_pwl.vh"

module test;
    localparam integer width   = 16;
    localparam integer depth   = 30;
    localparam integer bitwidth= 8;

    logic clk, clk_adc, rstb;

    logic [3:0] ii, next_ii;

    logic [bitwidth-1:0] values [width-1:0];
    logic [width-1:0]    signs;

    logic [bitwidth-1:0] values_retimed [width-1:0];
    logic [width-1:0]    signs_retimed;

    logic [bitwidth-1:0] prev_val;
    logic prev_sig;

    weight_clock #(.period(62.5ps)) clk_gen (.clk(clk));
    weight_clock #(.period(1ns)) clk_adc_gen (.clk(clk_adc));


    genvar k;
    generate
        for (k=0;k<Nti;k++) begin: genblk1
            //Reorder the slices
            assign values_r[k]  = values[(k%4)*4+(k>>2)];
            assign signs_r[k]   = signs[(k%4)*4+(k>>2)];
        end
    endgenerate


    always_comb begin
        next_ii  = ii + 1;
        prev_val = values[ii-1];
        prev_sig = signs[ii-1];
    end

    always @(posedge clk) begin
        values[ii] <= prev_val + 1;
        signs[ii]  <= prev_sig + 1;
        ii         <= next_ii;
    end

    
    ti_adc_retimer_v2 retimer_i (
        .clk_retimer(clk_adc),                // clock for serial to parallel retiming

        .in_data(values_r),                     // serial data
        .in_sign(signs_r),                // sign of serial data

        .mux_ctrl_1(16'b0000111111111111),
        .mux_ctrl_2(16'b1111111111110000),

        .out_data(values_retimed),            // parallel data
        .out_sign(signs_retimed)
    );

endmodule : test
