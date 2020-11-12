    add_ndr -name tx_out_buf -spacing {M1:M7 0.12} -width {M1:M3 0.12 M4:M7 0.4}
    setAttribute -net {itx/buf1/BTN itx/buf1/BTP ext_tx_outp ext_tx_outn} -non_default_rule tx_out_buf
