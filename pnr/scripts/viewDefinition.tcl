#############################
# TIMING
#############################
create_library_set -name wcl \
   -timing $wc_lib

create_library_set -name bcl \
   -timing $bc_lib

#create_op_cond -name wc_op \
#  -library_file [list $wc_lib] \
#  -P 1 \
#  -V 0.72 \
#  -T 125 \

#create_op_cond -name bc_op \
#  -library_file [list $bc_lib] \
#  -P 1 \
#  -V 0.88 \
#  -T 0 \

#create_timing_condition -name timing_max \
#  -library_sets wcl
##  -opcond  wc_op
#
#create_timing_condition -name timing_min \
#  -library_sets bcl
##  -opcond  bc_op

#############################
# RC
#############################

#create_rc_corner -name cworst_CC \
#  -T 125 \
#  -qx_tech_file $qrc_cworst_CC \
#  -preRoute_res 1 \
#  -postRoute_res 1 \
#  -preRoute_cap 1 \
#  -postRoute_cap 1 \
#  -postRoute_xcap 1 \
#  -preRoute_clkres 1 \
#  -preRoute_clkcap 1

create_rc_corner -name rcworst_CC \
  -T 125 \
  -qx_tech_file $qrc_rcworst_CC \
  -preRoute_res 1 \
  -postRoute_res 1 \
  -preRoute_cap 1 \
  -postRoute_cap 1 \
  -postRoute_xcap 1 \
  -preRoute_clkres 1 \
  -preRoute_clkcap 1

#create_rc_corner -name cbest_CC \
#  -T 0 \
#  -qx_tech_file $qrc_cbest_CC \
#  -preRoute_res 1 \
#  -postRoute_res 1 \
#  -preRoute_cap 1 \
#  -postRoute_cap 1 \
#  -postRoute_xcap 1 \
#  -preRoute_clkres 1 \
#  -preRoute_clkcap 1

create_rc_corner -name rcbest_CC \
  -T 0 \
  -qx_tech_file $qrc_rcbest_CC \
  -preRoute_res 1 \
  -postRoute_res 1 \
  -preRoute_cap 1 \
  -postRoute_cap 1 \
  -postRoute_xcap 1 \
  -preRoute_clkres 1 \
  -preRoute_clkcap 1

#############################
# Delay corner
#############################

#create_delay_corner -name max_cworst_CC \
#  -library_set wcl \
#  -rc_corner cworst_CC 

create_delay_corner -name max_rcworst_CC \
  -library_set wcl \
  -rc_corner rcworst_CC

#create_delay_corner -name min_cbest_CC \
#  -library_set bcl \
#  -rc_corner cbest_CC

create_delay_corner -name min_rcbest_CC \
  -library_set bcl \
  -rc_corner rcbest_CC


#############################
# Constraint mode
#############################

create_constraint_mode -name func \
   -sdc_files $sdc(prects)

#############################
# Analysis view
#############################

#create_analysis_view -name setup_cworst_CC \
#  -constraint_mode func \
#  -delay_corner max_cworst_CC 

#create_analysis_view -name hold_cbest_CC \
#  -constraint_mode func \
#  -delay_corner min_cbest_CC 

create_analysis_view -name setup_rcworst_CC \
  -constraint_mode func \
  -delay_corner max_rcworst_CC 

create_analysis_view -name hold_rcbest_CC \
  -constraint_mode func \
  -delay_corner min_rcbest_CC 

set_analysis_view \
  -setup setup_rcworst_CC \
  -hold hold_rcbest_CC 
