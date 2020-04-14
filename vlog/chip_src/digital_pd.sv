module digital_pd #(
    parameter integer width=8
) (
    input wire logic clk_p,
    input wire logic clk_n,

    input wire logic clk,
    input wire logic rstb,

    output reg signed [width-1:0] pd_out
);

    typedef enum logic [1:0] {COUNT_UP, RESET, COUNT_DOWN} pd_state_t;
    pd_state_t pd_state;

    logic count_up =  clk_p  && !clk_n;
    logic count_dn = !clk_p  &&  clk_p;

    always_ff @(posedge clk_p or negedge rstb) begin
        if(~rstb) begin
            pd_state <= RESET;
            pd_out <= 0;
        end else begin
            case (pd_state)
                RESET : begin
                    if (count_up) begin
                        pd_out <= 1;
                        pd_state <= COUNT_UP;
                    end else if(count_dn) begin
                        pd_out <= -1;
                        pd_state <= COUNT_DOWN;
                    end else begin
                        pd_out <= 0;
                        pd_state <= RESET;
                    end
                end
                COUNT_UP : begin
                    pd_out <= pd_out + 1;
                    pd_state <= clk_n ? RESET : COUNT_UP;
                end
                COUNT_DOWN: begin
                    pd_out <= pd_out - 1;
                    pd_state <= clk_p ? RESET : COUNT_DOWN;
                end
            endcase
        end
    end
endmodule : digital_pd