module dlatch_n #(
    parameter real td_nom = 15.0e-12,    // nominal delay in sec
    parameter real td_std = 0.0,         // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0          // rms random jitter in sec
) (
    input wire logic clk,
    input wire logic din,
    output reg dout
);
    // use precise timing
    timeunit 1fs;
    timeprecision 1fs;

    // import Delay object
    import model_pack::Delay;
    Delay dly_obj;

    // initialize class parameters
    real td;
    initial begin
        dly_obj = new(td_nom, td_std);
        td = dly_obj.td;
    end

    // implement gate behavior
    real rj;
    always @ (clk or din) begin
        if (!clk) begin
            rj = dly_obj.get_rj(rj_rms);
            dout <= #((td+rj)*1s) din;
        end
    end
endmodule
