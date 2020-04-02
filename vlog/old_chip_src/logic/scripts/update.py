import os.path
from glob import glob

from butterphy import extract_std_cell, abspath

THIS_DIR = os.path.dirname(abspath(__file__))
LOGIC_DIR = os.path.dirname(THIS_DIR)

def process_line(line, cell_dict):
    std_cell = extract_std_cell(line)

    if std_cell is not None:
        cell_dict[std_cell.name] = std_cell

def process_file(file_, cell_dict):
    with open(file_, 'r') as f:
        for line in f:
            process_line(line, cell_dict)

def main():
    rel_locs = [
        ('..', '..', 'analog_core', 'all')
    ]

    cell_dict = {}

    for rel_loc in rel_locs:
        abs_loc = os.path.join(THIS_DIR, *rel_loc)
        for file_ in glob(os.path.join(abs_loc, '*.*v')):
            process_file(file_, cell_dict)

    for std_cell in cell_dict.values():
        print(f'Writing template for standard cell {std_cell.name}.')

        fname = os.path.join(LOGIC_DIR, 'generate', f'{std_cell.name}.sv')
        with open(fname, 'w') as f:
            f.write(str(std_cell))

    print(f'Added {len(cell_dict)} models.')

if __name__ == '__main__':
    main()

