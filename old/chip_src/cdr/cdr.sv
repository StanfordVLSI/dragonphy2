module cdr #(
    parameter integer codeBitwidth=8,
    parameter integer numChannels=16,
    parameter integer numPIs=4,
    parameter integer piBitwidth=9
) (
    input wire logic signed [codeBitwidth-1:0] codes [numChannels-1:0],

    input wire logic rstb,
    input wire logic clk,

    output wire logic [piBitwidth-1:0] pi_ctl [numPIs-1:0]
);
    localparam depth=3;
    localparam centerBuffer=1;
    localparam pdBitwidth=codeBitwidth + $clog2(numChannels) + 1;

    logic        [codeBitwidth-1:0] ucodes       [numChannels-1:0];
    logic        [codeBitwidth-1:0] ucodes_buffer [numChannels-1:0][depth-1:0];

    logic        [codeBitwidth-1:0] flat_ucodes  [numChannels*depth-1:0];
    logic signed [codeBitwidth-1:0] flat_codes   [numChannels*depth-1:0];

    logic signed [pdBitwidth-1:0] pd_out;
    logic signed [1:0]            sc_out;
    logic [piBitwidth-1:0] int_pi_ctl;

    genvar gi;
    generate
        always_comb begin
            foreach(codes[gi]) begin
                ucodes[gi] = $unsigned(codes[gi]);
            end
            foreach(flat_ucodes[gi]) begin
                flat_codes[ gi] = $signed(flat_ucodes[gi]);
            end  
        end
    endgenerate

    buffer #(
        .numChannels(numChannels),
        .bitwidth   (codeBitwidth),
        .depth      (depth)
    ) cb_i (
        .in(ucodes),
        
        .clk   (clk),
        .rstb  (rstb),

        .buffer(ucodes_buffer)
    );
    
    flatten_buffer #(
        .numChannels(numChannels),
        .bitwidth   (codeBitwidth),
        .depth      (depth)
    ) fcb_i (
        .buffer     (ucodes_buffer),
        .flat_buffer(flat_ucodes)
    );

    mm_pd  #(
        .codeBitwidth(codeBitwidth),
        .pdBitwidth(pdBitwidth),
        .shiftBitwidth(4),
        .numChannels(numChannels),
        .centerBuffer(centerBuffer),
        .numBuffers(depth)
    ) mm_pd_i (
        .flat_codes(flat_codes),
        .shift_pd(4'd4),
        .pd_out(pd_out)
    );

    mm_sliding_control #(
        .slide_width(7),
        .pdBitwidth(pdBitwidth)
    ) slide_ctrl_i (
        .pd_in(pd_out),
        .clk(clk),
        .rstb(rstb),
        .out(sc_out)
    );

    mm_integrator #(
        .piBitwidth(piBitwidth)
    ) mm_int_i (
        .in(sc_out),
        .clk(clk),
        .rstb(rstb),
        .pi_ctl(int_pi_ctl)
    );


endmodule : cdr