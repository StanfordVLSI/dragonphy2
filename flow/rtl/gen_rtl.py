import os
import re
from pathlib import Path
from dragonphy import *

TOP_CELL = os.environ.get('design_name', 'dragonphy_top')
OUTPUT_FILE = 'design.v'
INC_DIRS = [get_dir('inc/new_asic')]

def resolve_include_file(name):
    if Path(name).is_absolute():
        return Path(name)
    else:
        for inc_dir in INC_DIRS:
            if (inc_dir / name).is_file():
                return (inc_dir / name)
        raise Exception(f'Could not find include file: {name}')

# build up a list of source files
src_files = []
src_files += [get_file('vlog/new_chip_src/jtag/jtag_intf.sv')]
src_files += get_deps_new_asic(TOP_CELL)

# generate the output text
output = ''
inc_pat = re.compile(r'\s*`include\s+"?([a-zA-Z0-9_./]+)"?')
for src_file in src_files:
    output += f'// Content from file: {src_file}\n'
    for line in open(src_file, 'r').readlines():
        match = inc_pat.match(line)
        if match is None:
            output += line
        else:
            filename = resolve_include_file(match.groups()[0])
            output += f'// Content from included file: {filename}\n'
            output += open(filename, 'r').read()
            output += '\n'
    output += '\n'

# create output directory
OUTPUT_DIR = Path('outputs')
OUTPUT_DIR.mkdir(exist_ok=True, parents=True)

# write output text
with open(OUTPUT_DIR / OUTPUT_FILE, 'w') as f:
    f.write(output)
