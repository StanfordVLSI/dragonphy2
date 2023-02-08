module error_tracker #(
    parameter integer width=16,
    parameter integer error_bitwidth=8,
    parameter integer addrwidth= 10,
    parameter integer flag_width=3,
    parameter integer sym_bitwidth=2
)(
    input logic        [sym_bitwidth*width-1:0]  prbs_flags,
    input logic        [sym_bitwidth*width-1:0]  prbs_flags_trigger,


    input logic signed [error_bitwidth-1:0]      est_error       [width-1:0],
    input logic signed [(2**sym_bitwidth-1)-1:0] encoded_symbols [width-1:0],
    input logic        [flag_width-1:0]          sd_flags        [width-1:0],


    input logic clk,
    input logic rstb,

    error_tracker_debug_intf.tracker errt_dbg_intf_i
);
    localparam integer sw = (2**sym_bitwidth-1);
    genvar gi, gj;

    logic signed [sw-1:0]             encoded_symbols_buffer [width-1:0][6:0];
    logic [width*2-1:0]               prbs_flags_buffer [0:0][2:0];
    logic signed [error_bitwidth-1:0] est_error_buffer [width-1:0][6:0];
    logic [flag_width-1:0]            sd_flags_buffer [width-1:0][6:0];


    logic [width*2-1:0] delayed_prbs_flags_trigger;
    logic [width*2-1:0] unpacked_prbs_flags [0:0];

    logic delayed_trigger; 

    assign unpacked_prbs_flags[0] = prbs_flags;

    logic [$clog2(width)-1:0] ones;

    always_ff @(posedge clk or negedge rstb) begin 
        if(~rstb) begin
            delayed_prbs_flags_trigger <= 0;
        end else begin
            delayed_prbs_flags_trigger <= prbs_flags_trigger;
        end
    end

    always_comb  begin
        ones = 0;
        for(int ii = 0; ii < 2*width; ii += 1) begin
            ones += delayed_prbs_flags_trigger[ii];
        end
        case (errt_dbg_intf_i.mode)
            0 : begin
                delayed_trigger = (ones > 0);
            end
            1 : begin
                delayed_trigger = (ones > 1);
            end
            2 : begin
                delayed_trigger = (ones > 2);
            end
            3 : begin
                delayed_trigger = (ones > 3);
            end
            default : begin
                delayed_trigger = (ones > 0);
            end
        endcase
    end 

    //Bits Pipeline
    signed_buffer #(
        .numChannels (width),
        .bitwidth    ((2**sym_bitwidth-1)),
        .depth       (6)
    ) sb_buff_i (
        .in      (encoded_symbols),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (encoded_symbols_buffer)
    );

    buffer #(
        .numChannels (1),
        .bitwidth    (width*2),
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
        .depth       (6)
    ) ee_buff_i (
        .in      (est_error),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (est_error_buffer)
    );

    buffer #(
        .numChannels (width),
        .bitwidth    (flag_width),
        .depth       (6)
    ) sf_buff_i (
        .in      (sd_flags),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (sd_flags_buffer)
    );

    logic signed [sw-1:0] flat_encoded_symbols [width*3-1:0];
    logic [width*2-1:0] flat_prbs_flags [2:0];

    logic signed [error_bitwidth-1:0] flat_est_error   [width*3-1:0];
    logic [flag_width-1:0] flat_sd_flags [width*3-1:0];
    logic pf_prbs_flags [width*3*sym_bitwidth-1:0];


    signed_flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (sw),
        .buff_depth (6),
        .slice_depth(2),
        .start      (2)
    ) sb_fb_i (
        .buffer    (encoded_symbols_buffer),
        .flat_slice(flat_encoded_symbols)
    );

    flatten_buffer_slice #(
        .numChannels(1),
        .bitwidth   (width*2),
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
        .buff_depth (6),
        .slice_depth(2),
        .start      (2)
    ) ee_fb_i (
        .buffer    (est_error_buffer),
        .flat_slice(flat_est_error)
    );

    flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (flag_width),
        .buff_depth (6),
        .slice_depth(2),
        .start      (2)
    ) sf_fb_i (
        .buffer    (sd_flags_buffer),
        .flat_slice(flat_sd_flags)
    );

    generate 
        for(gi =0; gi < 3; gi = gi + 1) begin
            for(gj = 0; gj < 2*width; gj = gj + 1) begin
                assign pf_prbs_flags[width*2*gi + gj]  = flat_prbs_flags[gi][gj];
            end
        end
    endgenerate

    error_tracker_core #(
        .width(width),
        .error_bitwidth(error_bitwidth),
        .addrwidth(addrwidth),
        .flag_width(flag_width),
        .sym_bitwidth(sym_bitwidth)
    ) errt_i (
        .trigger(delayed_trigger),

        .prbs_flags(pf_prbs_flags),
        .errors(flat_est_error),
        .symstream(flat_encoded_symbols),
        .sd_flags(flat_sd_flags),

        .clk(clk),
        .rstb(rstb),
        .errt_dbg_intf_i(errt_dbg_intf_i)
    );
endmodule : error_tracker
