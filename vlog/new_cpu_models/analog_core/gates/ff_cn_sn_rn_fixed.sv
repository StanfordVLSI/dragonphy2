module ff_cn_sn_rn_fixed #(
    parameter real td_nom = 15.0e-12,    // nominal delay in sec
    parameter real td_std = 0.0,         // std dev of nominal delay variation in sec
    parameter real rj_rms = 0.0          // rms random jitter in sec
) (
    input D,
    input CPN,
    input CDN,
    input SDN,
    output reg Q
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
    always @(negedge CPN or negedge CDN or negedge SDN) begin
        rj = dly_obj.get_rj(rj_rms);
        if (!CDN) begin
            Q <= #((td+rj)*1s) 0;
        end else if(!SDN) begin
            Q <= #((td+rj)*1s) 1;
        end else begin
            Q <= #((td+rj)*1s) D;
        end
    end
endmodule


