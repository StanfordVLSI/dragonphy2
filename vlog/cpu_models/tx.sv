`include "signals.sv"

`timescale 1s/1fs

module tx #(
    parameter real v_lo=-1.0,
    parameter real v_hi=+1.0
) (
    input wire logic data_i,
    `ANALOG_OUTPUT data_ana_o,
    input wire logic clk_i
);
    // initialize time/value memory to zeros
    localparam mem_len=50;
    real t_mem [mem_len];
    real v_mem [mem_len];
    initial begin
        for (int i=0; i<mem_len; i=i+1) begin
            t_mem[i]=0.0;
            v_mem[i]=0.0;
        end
    end

    // function to evaluate the step response at specific times
    // TODO: use interpolation to improve accuracy
    import step_resp_pack::*;
    function real eval_at(input real t);
        integer idx;
        idx = t/step_dt;
        if (idx < 0) begin
            eval_at = v_step[0];
        end else if (idx > (step_len-1)) begin
            eval_at = v_step[step_len-1];
        end else begin
            eval_at = v_step[idx];
        end
    endfunction

    // update the output of the transmitter
    real tmp;
    always @(posedge clk_i) begin
        // shift back memory
        for (int i=(mem_len-2); i>=0; i=i-1) begin
            t_mem[i+1]=t_mem[i];
            v_mem[i+1]=v_mem[i];
        end

        // add new values at index 0
        t_mem[0] = $realtime;
        v_mem[0] = (data_i ? v_hi : v_lo);

        // calculate output
        tmp = 0;
        for (int i = 0; i<(mem_len-1); i=i+1) begin
            tmp += v_mem[i] * (eval_at($realtime-t_mem[i+1])-eval_at($realtime-t_mem[i]));
        end

        // assign to the output
        data_ana_o.value <= tmp;
    end
endmodule
