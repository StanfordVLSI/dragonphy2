`timescale 100ps/1ps   //  Unit_time / Time precision

module tx_top_tb (
    output reg dout   // din to dout, X2
); // Module declaration

//Internal variables
wire [15:0] prbsdata;  //Output of the prbs generator
wire clk_prbs; // Clock for prbs generator
reg rst;  // Reset signal
reg clk_a;  // Input clock
wire clk_2;  // Clock clk_a divided by 2

wire cq;
wire ci;
wire cqb;
wire cib;

    logic [31:0] init_vals [16];              // Set the initial value for [15:0] 
    assign init_vals[0]  = 32'h0ffd4066;
    assign init_vals[1]  = 32'h38042b00;
    assign init_vals[2]  = 32'h001fffff;
    assign init_vals[3]  = 32'h39fbfe59;
    assign init_vals[4]  = 32'h1ffd40cc;
    assign init_vals[5]  = 32'h3e055e6a;
    assign init_vals[6]  = 32'h03ff554c;
    assign init_vals[7]  = 32'h3e0aa195;
    assign init_vals[8]  = 32'h1f02aa60;
    assign init_vals[9]  = 32'h31f401f3;
    assign init_vals[10] = 32'h00000555;
    assign init_vals[11] = 32'h300bab55;
    assign init_vals[12] = 32'h1f05559f;
    assign init_vals[13] = 32'h3f8afe65;
    assign init_vals[14] = 32'h07ff5566;
    assign init_vals[15] = 32'h7f8afccf;

    genvar i;  // Declare the generate variable
    generate
        for(i=0; i<16; i=i+1) begin
            prbs_generator_syn #(
                .n_prbs(32)
            ) prbs_b (
                .clk(clk_prbs),
                .rst(rst),
                .cke(1'b1),
                .init_val(init_vals[i]),
                .eqn(32'h100002),
                .inj_err(1'b0),
                .inv_chicken(2'b00),
                .out(prbsdata[i])
            );
        end
    endgenerate

tx_top tx_mux (
    .din(prbsdata), 
    .clk_q(ci),  // The clock inout must follow this order, (rising edge order) Q->I->QB->IB-Q
    .clk_i(cq),  // The clock is a quarter-rate clock with respect to output data rate
    .clk_qb(cib), // q, i, qb, ib spaced evenly within a clock cycle
    .clk_ib(cqb),
    .clk_prbsgen(clk_prbs),  // Output clock for 16-bit prbs generator
    .dout(dout)
);

//This phase interpolator takes a 8GHz clock to generate 4-phase 4GHz clock
fppi pi(.clkin(clk_a), .clk_Q(cq), .clk_I(ci), .clk_QB(cqb), .clk_IB(cib));

initial begin
    clk_a  = 1'b0; 
    rst = 1'b1;
    #10;
    rst = 1'b0; // Release the reset button of prbs generator

    //Set the simulation time
    #500 $finish;
end
    
    always #0.625 clk_a = ~clk_a; // #5 for 1 GHz

endmodule