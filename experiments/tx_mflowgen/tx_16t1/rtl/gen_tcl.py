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
inc_dir = get_dir('inc/asic')

# build up a list of source files
file_list = []
file_list += [get_file('vlog/pack/const_pack.sv')]
file_list += [get_file('vlog/chip_src/tx_16t1/tx_debug_intf.sv')]
file_list += get_deps_asic(e['design_name'], process=e['adk_name'])
file_list.pop(2)
print('loaded verilog source file list:', file_list)

# create the text of the TCL script
output = f'''\
# Set the search path for include files
set_app_var search_path "{inc_dir} $search_path"

# Read design
set file_list {tcl_list(file_list)}
analyze -format sverilog $file_list

# Elaborate the design target
elaborate {e['design_name']}
'''

# write output text
with open('outputs/read_design.tcl', 'w') as f:
    f.write(output)
