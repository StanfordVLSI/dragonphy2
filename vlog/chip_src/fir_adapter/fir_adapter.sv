module fir_adapter #(
    parameter integer codeBitwidth=8,
    parameter integer estBitwidth=10,
    parameter integer weightBitwidth=10,
    parameter integer gainBitwidth=5,
    parameter integer ffeDepth=10,
    parameter integer numChannels=16
)(
    input wire logic clk,
    input wire logic rst_n,

    input wire logic signed [codeBitwidth-1:0] adc_codes [numChannels-1:0],
    input wire logic signed [estBitwidth-1:0]  est_bits  [2*numChannels-1:0],

    input wire logic signed [gainBitwidth-1:0] gain,
    input wire logic signed [estBitwidth-1:0] target_level,
    input wire logic [$clog2(ffeDepth)-1:0] cur_pos,

    input wire logic signed [weightBitwidth-1:0] init_weights [ffeDepth-1:0],
    input wire logic use_init_weights,
    input wire logic load_init_weights,
    output wire logic signed [weightBitwidth-1:0] weights [ffeDepth-1:0]
);



    localparam int_weightBitwidth = 32; //estBitwidth + codeBitwidth + $clog2(numChannels);
    localparam shift_value = int_weightBitwidth - weightBitwidth;

    wire logic signed [estBitwidth-1:0] sliced_est_bits [2*numChannels-1:0];
    
    logic signed [int_weightBitwidth-1:0] internal_weights [ffeDepth-1:0];
    logic signed [int_weightBitwidth-1:0] next_internal_weights [ffeDepth-1:0];
    
    // synthesis translate_off 
    int f;
    string out_str;
    initial begin
        #0
        f = $fopen("adaptation_internal_weights.txt");
        //$dumpvars(0, fir_adapter);
        //$monitor("int_weights = %p", internal_weights);
        //$monitor("act_weights = %p", weights);
        $fmonitor(f, "%p\n", internal_weights);
    end
    // synthesis translate_on

    genvar gi;



    generate 
        for(gi = 0; gi < 2*numChannels; gi += 1) begin
            assign sliced_est_bits[gi] = est_bits[gi] > 0 ? target_level : -target_level;
        end

        for(gi = 0; gi < ffeDepth; gi += 1) begin
            assign weights[gi] = use_init_weights ? init_weights[gi] : (internal_weights[gi] >>> shift_value);
        end
    endgenerate

    always_comb begin
        int ii;
        for(ii = 0; ii < ffeDepth; ii += 1) begin
            next_internal_weights[ii] = internal_weights[ii] ;//+ ((adc_codes[0] * (sliced_est_bits[numChannels + ii+cur_pos-ffeDepth+1] - est_bits[numChannels + ii+cur_pos-ffeDepth+1])) <<< gain);
        end
    end
    
    int jj;
    always_ff @(posedge clk or negedge rst_n) begin : proc_
        if(~rst_n) begin
            for(jj = 0; jj < ffeDepth; jj += 1) begin
                internal_weights[jj] <= 0;
            end
        end else begin
            for(jj = 0; jj < ffeDepth; jj += 1) begin
                internal_weights[jj] <= load_init_weights ? (init_weights[jj] <<< shift_value) : next_internal_weights[jj];
            end
        end
    end



endmodule
