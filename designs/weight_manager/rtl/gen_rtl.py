import os
import re
from pathlib import Path
from dragonphy import *

OUTPUT_FILE = 'design.v'

def remove_dup(seq):
    # fast method to remove duplicates from a list while preserving order
    # source: Raymond Hettinger (https://twitter.com/raymondh/status/944125570534621185)
    return list(dict.fromkeys(seq))

# build up a list of source files
src_files = []
src_files += get_deps_new_asic(impl_file=get_file('vlog/new_chip_src/digital_core/dsp_debug_intf.sv'))
src_files += get_deps_new_asic(impl_file=get_file('vlog/new_chip_src/weight_manager/wme_debug_intf.sv'))
src_files += get_deps_new_asic(impl_file='weight_manager_insts.sv')
src_files = remove_dup(src_files)

# generate the output text
output = ''

for src_file in src_files:
    output += f'// Content from file: {src_file}\n'
    output += open(src_file, 'r').read()
    output += '\n'

# create output directory
OUTPUT_DIR = Path('outputs')
OUTPUT_DIR.mkdir(exist_ok=True, parents=True)

# write output text
with open(OUTPUT_DIR / OUTPUT_FILE, 'w') as f:
    f.write(output)
