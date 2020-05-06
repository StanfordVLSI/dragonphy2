import os
import re
from pathlib import Path
from dragonphy import *

TOP_CELL = os.environ.get('design_name', 'weight_manager')
OUTPUT_FILE = 'design.v'

# build up a list of source files
src_files = []
src_files += get_deps_new_asic(TOP_CELL)

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
