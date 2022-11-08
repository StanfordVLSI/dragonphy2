xvlog -sv sliding_detector_single_slice.sv
xvlog -sv test_vec_gpack.sv
xvlog -sv fp_checker.sv
xvlog -sv ov_tb.sv
xelab overflow_testbench -s top_sim
xsim top_sim -R