module error_tracker #(
    parameter integer width=16,
    parameter integer error_bitwidth=8,
    parameter integer addrwidth= 10,
    parameter integer flag_width=2
)(
    input logic        [width-1:0]          prbs_flags,
    input logic        [width-1:0]          prbs_flags_trigger,


    input logic signed [error_bitwidth-1:0] est_error   [width-1:0],
    input logic                             sliced_bits [width-1:0],
    input logic        [flag_width-1:0]     sd_flags    [width-1:0],

    input logic [7:0] prbs_flags_delay,
    input logic [7:0] prbs_flags_trigger_delay,
    input logic [7:0] est_error_delay,
    input logic [7:0] sliced_bits_delay,
    input logic [7:0] sd_flags_delay,


    input logic clk,
    input logic rstb,

    error_tracker_debug_intf.tracker errt_dbg_intf_i
);
    genvar gi, gj;

    logic sliced_bits_buffer [width-1:0][6:0];
    logic [width-1:0] prbs_flags_buffer [0:0][2:0];
    logic signed [error_bitwidth-1:0] est_error_buffer [width-1:0][6:0];
    logic [flag_width-1:0] sd_flags_buffer [width-1:0][6:0];
    
    logic [7:0]     sliced_bits_buffer_delay[6:0];
    logic [7:0]     prbs_flags_buffer_delay[2:0];
    logic [7:0]     est_error_buffer_delay[6:0];
    logic [7:0]     sd_flags_buffer_delay[6:0];

    logic [width-1:0] delayed_prbs_flags_trigger;
    logic [7:0] delayed_prbs_flags_trigger_delay;

    logic [width-1:0] unpacked_prbs_flags [0:0];
    logic [7:0] unpacked_prbs_flags_delay;

    logic delayed_trigger; 

    assign unpacked_prbs_flags[0] = prbs_flags;
    assign unpacked_prbs_flags_delay = prbs_flags_delay;
    assign delayed_prbs_flags_trigger_delay = prbs_flags_trigger_delay + 16;

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
        for(int ii = 0; ii < width; ii += 1) begin
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
    /*
    // synthesis translate off
    always_ff @(posedge clk or negedge rstb) begin 
        $display("sliced_bits_buffer_delay: %p", sliced_bits_buffer_delay);
        $display("prbs_flags_buffer_delay:  %p", prbs_flags_buffer_delay);
        $display("est_error_buffer_delay:   %p", est_error_buffer_delay);
        $display("sd_flags_buffer_delay:    %p", sd_flags_buffer_delay);
        $display("flat_sliced_bits_delay:   %p", flat_sliced_bits_delay);
        $display("flat_prbs_flags_delay:    %p", flat_prbs_flags_delay);
        $display("flat_est_error_delay:     %p", flat_est_error_delay);
        $display("flat_sd_flags_delay:      %p", flat_sd_flags_delay);
        $display("delayed_trigger: %p", prbs_flags_buffer_delay[1]);
        $display("sliced_bits:          %p",flat_sliced_bits);
        $display("unpacked_prbs_flags:  %p",flat_prbs_flags);
        $display("est_error:            %p",flat_est_error);
        $display("prbs_flags_trigger:             %p",prbs_flags_trigger);
        $display("prbs_flags_trigger:             %p",prbs_flags_trigger);
        $display("prbs_flags_trigger_delay:             %p",prbs_flags_trigger_delay);
        $display("delayed_prbs_flags_trigger:             %p",delayed_prbs_flags_trigger);
        $display("delayed_prbs_flags_trigger_delay: %p", delayed_prbs_flags_trigger_delay);
    end
    // synthesis translate_on
*/
    //Bits Pipeline
    buffer #(
        .numChannels (width),
        .bitwidth    (1),
        .depth       (6)
    ) sb_buff_i (
        .in      (sliced_bits),
        .in_delay(sliced_bits_delay),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (sliced_bits_buffer),
        .buffer_delay(sliced_bits_buffer_delay)
    );

    buffer #(
        .numChannels (1),
        .bitwidth    (width),
        .depth       (2)
    ) ps_buff_i (
        .in      (unpacked_prbs_flags),
        .in_delay(unpacked_prbs_flags_delay),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (prbs_flags_buffer),
        .buffer_delay(prbs_flags_buffer_delay)
    );

    signed_buffer #(
        .numChannels (width),
        .bitwidth    (error_bitwidth),
        .depth       (6)
    ) ee_buff_i (
        .in      (est_error),
        .in_delay(est_error_delay),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (est_error_buffer),
        .buffer_delay(est_error_buffer_delay)
    );

    buffer #(
        .numChannels (width),
        .bitwidth    (flag_width),
        .depth       (6)
    ) sf_buff_i (
        .in      (sd_flags),
        .in_delay(sd_flags_delay),
        .clk     (clk),
        .rstb    (1'b1),
        .buffer  (sd_flags_buffer),
        .buffer_delay(sd_flags_buffer_delay)
    );

    logic flat_sliced_bits [width*3-1:0];
    logic [width-1:0] flat_prbs_flags [2:0];

    logic signed [error_bitwidth-1:0] flat_est_error   [width*3-1:0];
    logic [flag_width-1:0] flat_sd_flags [width*3-1:0];
    logic [width*3-1:0] pf_sliced_bits;
    logic [width*3-1:0] pf_prbs_flags;

    logic [7:0] flat_sliced_bits_delay;
    logic [7:0] flat_prbs_flags_delay;
    logic [7:0] flat_est_error_delay;
    logic [7:0] flat_sd_flags_delay;

    flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (1),
        .buff_depth (6),
        .slice_depth(2),
        .start      (2)
    ) sb_fb_i (
        .buffer    (sliced_bits_buffer),
        .buffer_delay(sliced_bits_buffer_delay),
        .flat_slice(flat_sliced_bits),
        .flat_slice_delay(flat_sliced_bits_delay)
    );

    flatten_buffer_slice #(
        .numChannels(1),
        .bitwidth   (width),
        .buff_depth (2),
        .slice_depth(2),
        .start      (0)
    ) ps_fb_i (
        .buffer    (prbs_flags_buffer),
        .buffer_delay(prbs_flags_buffer_delay),
        .flat_slice(flat_prbs_flags),
        .flat_slice_delay(flat_prbs_flags_delay)
    );

    signed_flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (error_bitwidth),
        .buff_depth (6),
        .slice_depth(2),
        .start      (2)
    ) ee_fb_i (
        .buffer    (est_error_buffer),
        .buffer_delay(est_error_buffer_delay),
        .flat_slice(flat_est_error),
        .flat_slice_delay(flat_est_error_delay)
    );

    flatten_buffer_slice #(
        .numChannels(width),
        .bitwidth   (flag_width),
        .buff_depth (6),
        .slice_depth(2),
        .start      (2)
    ) sf_fb_i (
        .buffer    (sd_flags_buffer),
        .buffer_delay(sd_flags_buffer_delay),
        .flat_slice(flat_sd_flags),
        .flat_slice_delay(flat_sd_flags_delay)
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
        .addrwidth(addrwidth),
        .flag_width(flag_width)
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
