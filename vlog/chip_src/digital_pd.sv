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

    always_ff @(posedge clk or posedge clk_p or posedge clk_n or negedge rstb) begin
        if(~rstb) begin
            pd_state <= RESET;
            pd_out <= 0;
        end else begin
            case (pd_state)
                RESET : begin
                    if (clk_p) begin
                        pd_out <= 1;
                        pd_state <= COUNT_UP;
                    end else if(clk_n) begin
                        pd_out <= -1;
                        pd_state <= COUNT_DOWN;
                    end else begin
                        pd_out <= 0;
                        pd_state <= RESET;
                    end
                end
                COUNT_UP : begin
                    if(clk_n) begin
                        pd_out <= 0;
                        pd_state <= RESET
                    end else begin
                        pd_out <= pd_out + 1;
                        pd_state <= COUNT_UP;
                    end
                end
                COUNT_DOWN: begin
                    if(clk_p) begin
                        pd_out <= 0;
                        pd_state <= RESET
                    end else begin
                        pd_out <= pd_out - 1;
                        pd_state <= COUNT_DOWN;
                    end
                end
            endcase
        end
    end
endmodule : digital_pd