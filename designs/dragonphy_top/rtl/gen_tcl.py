import os
from dragonphy import *

# convenience function that creates a nicely formatted TCL list
def tcl_list(vals, indent='    ', nl='\n'):
    retval = f' \\{nl}{indent}'.join(f'{{{val}}}' for val in vals)
    retval = '[list ' + retval + f' \\{nl}]'
    return retval

# shorten variable name for readability
e = os.environ

# determine the search path for include files
inc_dir = get_dir('inc/new_asic')

# build up a list of source files
file_list = []
file_list += [get_file('vlog/new_chip_src/jtag/jtag_intf.sv')]
file_list += get_deps_new_asic(e['design_name'], process=e['adk_name'])

# create the text of the TCL script
output = f'''\
# set the search path (for include files)
set_app_var search_path "{inc_dir} $search_path"

# read design
set file_list {tcl_list(file_list)}
analyze -format sverilog $file_list

# change to lower insensitive names to pass LVS
define_name_rules verilog -type net -allowed "a-z0-9_[]" -add_dummy_nets
report_name_rules verilog  

# Elaborate the design target: check verilog syntax here
elaborate {e['design_name']}

change_names -rules verilog -hierarchy -verbose 
'''

# write output text
with open('outputs/read_design.tcl', 'w') as f:
    f.write(output)

