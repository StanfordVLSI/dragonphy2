/********************************************************************
filename: snh_1st.sv

Description:
Behavioal model of 1st-level S&H circuit

Assumptions:

Todo:

********************************************************************/
`include "mLingua_pwl.vh"

`default_nettype none

module snh_1st import const_pack::*; (
    input pwl inp,
    input pwl inn,

    input wire logic clk,

    output pwl outp,
    output pwl outn 
);

PWLMethod pm = new;
`get_timeunit

real t0;

// track mode
always @(clk, inp.a, inp.b) 
    if (clk) begin
        t0 = `get_time;
        outp = '{pm.eval(inp,t0),inp.b, t0};
        //outp = inp;
    end

always @(clk, inn.a, inn.b) 
    if (clk) begin
        t0 = `get_time;
        outn = '{pm.eval(inn,t0),inn.b, t0};
        //outn = inn;
    end

// hold mode
always @(negedge clk) begin
    t0 = `get_time;
    outp = '{pm.eval(outp, t0), 0.0, t0};
    outn = '{pm.eval(outn, t0), 0.0, t0};
end

endmodule

`default_nettype wire
