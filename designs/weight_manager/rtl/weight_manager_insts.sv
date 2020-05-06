module weight_manager_insts import const_pack::*; (
    input wire logic clk_adc,
    input wire logic rstb,
    wme_debug_intf.wme wdbg_intf_i,
    dsp_debug_intf.dsp dsp_dbg_intf_i
);
    weight_manager #(.width(Nti), .depth(10), .bitwidth(10)) wme_ffe_i (
        .data    (wdbg_intf_i.wme_ffe_data),
        .inst    (wdbg_intf_i.wme_ffe_inst),
        .exec    (wdbg_intf_i.wme_ffe_exec),
        .clk     (clk_adc),
        .rstb    (rstb),
        .read_reg(wdbg_intf_i.wme_ffe_read),
        .weights (dsp_dbg_intf_i.weights)
    );

    weight_manager #(.width(Nti), .depth(30), .bitwidth(8)) wme_channel_est_i (
        .data    (wdbg_intf_i.wme_mlsd_data),
        .inst    (wdbg_intf_i.wme_mlsd_inst),
        .exec    (wdbg_intf_i.wme_mlsd_exec),
        .clk     (clk_adc),
        .rstb    (rstb),
        .read_reg(wdbg_intf_i.wme_mlsd_read),
        .weights (dsp_dbg_intf_i.channel_est)
    );
endmodule
