from pathlib import Path
from dragonphy import *

TOP_CELL = 'prbs_checker'
OUTPUT_FILE = 'design.v'

# build up a list of source files
src_files = []
src_files += get_deps_new_asic(TOP_CELL)

# create output directory
OUTPUT_DIR = Path('outputs')
OUTPUT_DIR.mkdir(exist_ok=True, parents=True)

# write source files in order
with open(OUTPUT_DIR / OUTPUT_FILE, 'w') as f:
    for src_file in src_files:
        f.write(f'// Content from file: {src_file}\n')
        f.write(open(src_file, 'r').read())
        f.write('\n')
