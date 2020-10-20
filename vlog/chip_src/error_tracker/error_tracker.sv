module error_tracker #(
    parameter integer width=16,
    parameter integer error_bitwidth=8,
    parameter integer addrwidth= 12
)(
    input logic        [width-1:0]          prbs_flags,

    input logic signed [error_bitwidth-1:0] est_error   [width-1:0],
    input logic                             sliced_bits [width-1:0],
    input logic        [1:0]                sd_flags    [width-1:0],

    input logic clk,
    input logic rstb,

    error_tracker_debug_intf.tracker errt_dbg_intf_i
);
    genvar gi, gj;

    logic sliced_bits_buffer [width-1:0][2:0];
    logic [width-1:0] prbs_flags_buffer [0:0][2:0];
    logic signed [error_bitwidth-1:0] est_error_buffer [width-1:0][2:0];
    logic [1:0] sd_flags_buffer [width-1:0][2:0];
    
    logic [width-1:0] unpacked_prbs_flags [0:0];

    assign unpacked_prbs_flags[0] = prbs_flags;

    logic delayed_trigger; 
    always_ff @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            delayed_trigger <= 0;
        end else begin
            delayed_trigger <= |prbs_flags_buffer[0][1];
        end
    end


    
    //Bits Pipeline
    buffer #(
        .numChannels (width),
        .bitwidth    (1),
        .depth       (2)
    ) sb_buff_i (
        .in      (sliced_bits),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (sliced_bits_buffer)
    );

    buffer #(
        .numChannels (1),
        .bitwidth    (width),
        .depth       (2)
    ) ps_buff_i (
        .in      (unpacked_prbs_flags),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (prbs_flags_buffer)
    );

    signed_buffer #(
        .numChannels (width),
        .bitwidth    (error_bitwidth),
        .depth       (2)
    ) ee_buff_i (
        .in      (est_error),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (est_error_buffer)
    );

    buffer #(
        .numChannels (width),
        .bitwidth    (2),
        .depth       (2)
    ) sf_buff_i (
        .in      (sd_flags),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (sd_flags_buffer)
    );

    logic flat_sliced_bits [width*3-1:0];
    logic [width-1:0] flat_prbs_flags [2:0];

    logic signed [error_bitwidth-1:0] flat_est_error   [width*3-1:0];
    logic [1:0] flat_sd_flags [width*3-1:0];
    logic [width*3-1:0] pf_sliced_bits;
    logic [width*3-1:0] pf_prbs_flags;

    flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (1),
        .buff_depth (2),
        .slice_depth(2),
        .start      (0)
    ) sb_fb_i (
        .buffer    (sliced_bits_buffer),
        .flat_slice(flat_sliced_bits)
    );

    flatten_buffer_slice #(
        .numChannels(1),
        .bitwidth   (width),
        .buff_depth (2),
        .slice_depth(2),
        .start      (0)
    ) ps_fb_i (
        .buffer    (prbs_flags_buffer),
        .flat_slice(flat_prbs_flags)
    );

    signed_flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (error_bitwidth),
        .buff_depth (2),
        .slice_depth(2),
        .start      (0)
    ) ee_fb_i (
        .buffer    (est_error_buffer),
        .flat_slice(flat_est_error)
    );

    flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (2),
        .buff_depth (2),
        .slice_depth(2),
        .start      (0)
    ) sf_fb_i (
        .buffer    (sd_flags_buffer),
        .flat_slice(flat_sd_flags)
    );

    generate 
        for(gi =0 ; gi < width*3; gi = gi + 1) begin
            assign pf_sliced_bits[gi] = flat_sliced_bits[gi]; 
        end
        for(gi =0; gi < 3; gi = gi + 1) begin
            for(gj = 0; gj < width; gj = gj + 1) begin
                assign pf_prbs_flags[width*gi + gj]  = flat_prbs_flags[gi][gj];
            end
        end
    endgenerate

    error_tracker_core #(
        .width(width),
        .error_bitwidth(error_bitwidth),
        .addrwidth(addrwidth)
    ) errt_i (
        .trigger(delayed_trigger),

        .prbs_flags(pf_prbs_flags),
        .errors(flat_est_error),
        .bitstream(pf_sliced_bits),
        .sd_flags(flat_sd_flags),

        .clk(clk),
        .rstb(rstb),
        .errt_dbg_intf_i(errt_dbg_intf_i)
    );
endmodule : error_tracker