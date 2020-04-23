
#################################
# ignored clock sinks
#################################

set_ccopt_property -pin iADC*/iV2T_clock_gen/*/CPN sink_type stop
set_ccopt_property -pin iADC*/ipm_mux0_dont_touch/I0 sink_type ignore
set_ccopt_property -pin */iPM/*/CP sink_type ignore

set_ccopt_property -pin iPI_0__iPI/$PI_clk_in_cell_name/I sink_type stop
set_ccopt_property -pin iPI_1__iPI/$PI_clk_in_cell_name/I sink_type stop
set_ccopt_property -pin iPI_2__iPI/$PI_clk_in_cell_name/I sink_type stop
set_ccopt_property -pin iPI_3__iPI/$PI_clk_in_cell_name/I sink_type stop



create_ccopt_clock_tree -name clk_pi -source iinbuf/out -no_skew_group
create_ccopt_skew_group -name clk_pi/func -source iinbuf/out -sink iPI_0__iPI/$PI_clk_in_cell_name/I 
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iPI_1__iPI/$PI_clk_in_cell_name/I
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iPI_2__iPI/$PI_clk_in_cell_name/I
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iPI_3__iPI/$PI_clk_in_cell_name/I

modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep0/iV2T_clock_gen/en_sync_out_reg/CPN
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep0/iV2T_clock_gen/count_reg_0_/CPN
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep0/iV2T_clock_gen/count_reg_1_/CPN
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep0/iV2T_clock_gen/iV2T_buffer_dont_touch/clk_div_sampled_reg/Q_reg/CPN

modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep1/iV2T_clock_gen/en_sync_out_reg/CPN
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep1/iV2T_clock_gen/count_reg_0_/CPN
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep1/iV2T_clock_gen/count_reg_1_/CPN
modify_ccopt_skew_group -skew_group clk_pi/func -add_sinks iADCrep1/iV2T_clock_gen/iV2T_buffer_dont_touch/clk_div_sampled_reg/Q_reg/CPN


#################################
## skew group for clk_interp_sw
#################################

set file [open clk_interp_sw_net.txt w]
puts $file "clk_interp_sw[0]"
puts $file "clk_interp_sw[1]"
puts $file "clk_interp_sw[2]"
puts $file "clk_interp_sw[3]"
close $file

deleteBufferTree -selNetFile clk_interp_sw_net.txt

#set_ccopt_property opt_ignore true -clock_tree clk_pi 
#set_ccopt_property opt_ignore true -clock_tree clk_cdr 
#set_ccopt_property opt_ignore true -clock_tree clk_async 

set_ccopt_property sink_type stop -pin iSnH/ISWp0/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWp1/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWp2/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWp3/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWp0/CLKB
set_ccopt_property sink_type stop -pin iSnH/ISWp1/CLKB
set_ccopt_property sink_type stop -pin iSnH/ISWp2/CLKB
set_ccopt_property sink_type stop -pin iSnH/ISWp3/CLKB

set_ccopt_property sink_type stop -pin iSnH/ISWn0/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWn1/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWn2/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWn3/CLK
set_ccopt_property sink_type stop -pin iSnH/ISWn0/CLKB
set_ccopt_property sink_type stop -pin iSnH/ISWn1/CLKB
set_ccopt_property sink_type stop -pin iSnH/ISWn2/CLKB
set_ccopt_property sink_type stop -pin iSnH/ISWn3/CLKB



create_ccopt_clock_tree -name pi_0_clk_sw -source iPI_0__iPI/$PI_clk_out_sw_cell_name/ZN -no_skew_group
create_ccopt_skew_group -name pi_0_clk_sw/func -source iPI_0__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp0/CLK iSnH/ISWn0/CLK} 
#create_ccopt_skew_group -name pi_0_clk_sw/func -source iPI_0__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp0/CLK iSnH/ISWn0/CLK iSnH/ISWp0/CLKB iSnH/ISWn0/CLKB} 

create_ccopt_clock_tree -name pi_1_clk_sw -source iPI_1__iPI/$PI_clk_out_sw_cell_name/ZN -no_skew_group
create_ccopt_skew_group -name pi_1_clk_sw/func -source iPI_1__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp1/CLK iSnH/ISWn1/CLK} 
#create_ccopt_skew_group -name pi_1_clk_sw/func -source iPI_1__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp1/CLK iSnH/ISWn1/CLK iSnH/ISWp1/CLKB iSnH/ISWn1/CLKB} 

create_ccopt_clock_tree -name pi_2_clk_sw -source iPI_2__iPI/$PI_clk_out_sw_cell_name/ZN -no_skew_group
create_ccopt_skew_group -name pi_2_clk_sw/func -source iPI_2__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp2/CLK iSnH/ISWn2/CLK} 
#create_ccopt_skew_group -name pi_2_clk_sw/func -source iPI_2__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp2/CLK iSnH/ISWn2/CLK iSnH/ISWp2/CLKB iSnH/ISWn2/CLKB} 

create_ccopt_clock_tree -name pi_3_clk_sw -source iPI_3__iPI/$PI_clk_out_sw_cell_name/ZN -no_skew_group
create_ccopt_skew_group -name pi_3_clk_sw/func -source iPI_3__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp3/CLK iSnH/ISWn3/CLK} 
#create_ccopt_skew_group -name pi_3_clk_sw/func -source iPI_3__iPI/$PI_clk_out_sw_cell_name/ZN -sink {iSnH/ISWp3/CLK iSnH/ISWn3/CLK iSnH/ISWp3/CLKB iSnH/ISWn3/CLKB} 

get_ccopt_property -skew_group pi_0_clk_sw/func sinks_active
get_ccopt_property -skew_group pi_1_clk_sw/func sinks_active
get_ccopt_property -skew_group pi_2_clk_sw/func sinks_active
get_ccopt_property -skew_group pi_3_clk_sw/func sinks_active


set_ccopt_property target_skew 0.005 -skew pi_0_clk_sw/func
set_ccopt_property target_skew 0.005 -skew pi_1_clk_sw/func
set_ccopt_property target_skew 0.005 -skew pi_2_clk_sw/func
set_ccopt_property target_skew 0.005 -skew pi_3_clk_sw/func

set_ccopt_property target_max_trans 0.03 -clock_tree pi_0_clk_sw
set_ccopt_property target_max_trans 0.03 -clock_tree pi_1_clk_sw
set_ccopt_property target_max_trans 0.03 -clock_tree pi_2_clk_sw
set_ccopt_property target_max_trans 0.03 -clock_tree pi_3_clk_sw


######################################
# skew balance btw clk_slice & clk_sw
######################################
create_ccopt_skew_group -name pi_0_clk/merged -balance_skew_group {pi_0_clk_slice/func pi_0_clk_sw/func} -target_skew 0.005 
create_ccopt_skew_group -name pi_1_clk/merged -balance_skew_group {pi_1_clk_slice/func pi_1_clk_sw/func} -target_skew 0.005 
create_ccopt_skew_group -name pi_2_clk/merged -balance_skew_group {pi_2_clk_slice/func pi_2_clk_sw/func} -target_skew 0.005 
create_ccopt_skew_group -name pi_3_clk/merged -balance_skew_group {pi_3_clk_slice/func pi_3_clk_sw/func} -target_skew 0.005 


#set_ccopt_property update_io_latency false
#set_ccopt_property post_conditioning false
#set_ccopt_property use_estimated_routes_during_final_implementation true

#ccopt_design -cts






