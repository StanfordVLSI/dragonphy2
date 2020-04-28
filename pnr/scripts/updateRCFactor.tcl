foreach corner [all_rc_corners] {
  update_rc_corner -name ${corner} \
    -preRoute_res 1.1 \
    -postRoute_res {1 1 1} \
    -preRoute_cap 1.2 \
    -postRoute_cap {1 1 1} \
    -postRoute_xcap {1 1 1} \
    -preRoute_clkres 1 \
    -preRoute_clkcap 1 \
    -postRoute_clkcap {1 1 1} \
    -postRoute_clkres {1 1 1}
} 
