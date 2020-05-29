`include "signals.sv"
`timescale 1s/1fs

module chan (
    `ANALOG_INPUT data_ana_i,
    `ANALOG_OUTPUT data_ana_o,
    input wire logic cke
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

    // update memory
    always @(data_ana_i.value) begin
        // shift back memory
        for (int i=(mem_len-2); i>=0; i=i-1) begin
            t_mem[i+1]=t_mem[i];
            v_mem[i+1]=v_mem[i];
        end

        // add new values at index 0
        t_mem[0] = $realtime;
        v_mem[0] = data_ana_i.value;
    end

    // function to evaluate the step response at specific times
    import step_resp_pack::*;
    function real eval_at(input real t);
        integer idx;
        real weight;
        idx = $floor(t/step_dt);
        if (idx < 0) begin
            eval_at = v_step[0];
        end else if (idx >= (step_len-1)) begin
            eval_at = v_step[step_len-1];
        end else begin
            weight = (t/step_dt) - idx;
            eval_at = (1-weight)*v_step[idx] + weight*v_step[idx+1];
        end
    endfunction

    // update the output of the transmitter
    real tmp;
    always @(data_ana_o.req) begin
        // calculate output
        tmp = 0;
        for (int i=0; i<(mem_len-1); i=i+1) begin
            if (i==0) begin
                tmp += v_mem[i]*eval_at($realtime-t_mem[i]);
            end else begin
                tmp += v_mem[i]*(eval_at($realtime-t_mem[i])-eval_at($realtime-t_mem[i-1]));
            end
        end

        // assign to the output
        data_ana_o.value = tmp;

        // acknowledge request
        ->>data_ana_o.ack;
    end
endmodule
