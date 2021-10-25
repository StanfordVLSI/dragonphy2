##------------------------------------------------------
## pget cell names
##------------------------------------------------------
set PI_clk_in_cell_name [get_property [get_cells -of_object [get_nets clk_in]] name]
set PI_clk_out_sw_cell_name [get_property [get_cells -of_object [get_nets clk_out_sw]] name]
set PI_clk_out_slice_cell_name [get_property [get_cells -of_object [get_nets clk_out_slice]] name]

##------------------------------------------------------
## pnr variable file-out 
##------------------------------------------------------
set fid [open "${pnrDir}/pnr_vars.txt" a]
puts -nonewline $fid "PI_clk_in_cell_name:$PI_clk_in_cell_name\n"
puts -nonewline $fid "PI_clk_out_sw_cell_name:$PI_clk_out_sw_cell_name\n"
puts -nonewline $fid "PI_clk_out_slice_cell_name:$PI_clk_out_slice_cell_name\n"
close $fid




