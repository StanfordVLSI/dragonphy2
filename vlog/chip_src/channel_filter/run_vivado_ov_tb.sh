xvlog -sv channel_filter.sv
xvlog -sv chan_ov_tb.sv
xelab tb -s top_sim
xsim top_sim -R