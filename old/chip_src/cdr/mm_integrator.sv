module mm_integrator #(
    parameter integer piBitwidth=9
) (
    input logic signed [1:0] in,
    input logic clk,
    input logic rstb,

    output logic [piBitwidth-1:0] pi_ctl
);
    
    logic [piBitwidth-1:0] next_int_pi_ctl;
    logic signed [piBitwidth-1:0] int_pi_ctl;

    always_comb begin
        next_int_pi_ctl = int_pi_ctl + in;
        pi_ctl          = next_int_pi_ctl;
    end
    

    always_ff @(posedge clk or negedge rstb) begin : proc_
        if(~rstb) begin
            int_pi_ctl <= 0;
        end else begin
            int_pi_ctl <= next_int_pi_ctl;
        end
    end
endmodule : mm_integrator