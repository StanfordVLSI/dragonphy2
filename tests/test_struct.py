import dragonphy
from pathlib import Path

def test_struct():
    top = Path(dragonphy.__file__).parent.parent
    subdirs = [top / 'src', top / 'verif']

    # make sure no verilog directly in the subdirectories
    for d in subdirs:
        assert len(list(d.glob('*.*v'))) == 0, f'Please do not place Verilog code directly in the {d} folder.'

    # get a flat list of directories to look at
    look_at = []
    for x in subdirs:
        for y in x.iterdir():
            if y.is_dir:
                look_at.append(y)

    # make sure no verilog directly in the subdirectories
    names = set()
    for d in look_at:
        assert len(list(d.glob('*.*v'))) == 0, f'Please do not place Verilog code directly in the {d} folder.'
        assert d.stem not in names, f'A module called {d.stem} has already been defined.'
        names.add(d.stem)

    # check names of the directories for each module
    allowed = {'beh', 'fpga', 'syn', 'spice', 'layout', 'struct', 'all'}
    for d in look_at:
        for x in d.iterdir():
            if x.is_dir and x.stem not in allowed:
                print(f'The folder name {x} is invalid.')
                print(f'Permitted module types are: {allowed}.')
                raise Exception('Invalid folder name.')

    # make sure that source files are named correctly
    for d in look_at:
        for x in d.iterdir():
            if x.is_dir:
                assert len(list(x.glob(f'{d.stem}.*v'))) == 1, f'Need to have exactly one file matching pattern {x}/{d.stem}.*v'

if __name__ == '__main__':
    test_struct()
