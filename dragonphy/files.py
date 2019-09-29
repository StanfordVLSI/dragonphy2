from pathlib import Path

TOP_DIR = Path(__file__).resolve().parent.parent
VIEW_DIRS = ['src', 'verif']
VIEW_NAMES = {'beh', 'fpga', 'syn', 'spice', 'layout', 'struct', 'all'}

def get_file(path):
    return Path(TOP_DIR, path)

def get_dir(path):
    # alias for get_file
    return get_file(path)

def get_files(*args):
    return [get_file(path) for path in args]

def get_dirs(*args):
    # alias for get_files
    return get_files(*args)

def get_view(cell, view):
    for view_dir in VIEW_DIRS:
        path = Path(TOP_DIR, view_dir, cell, view)
        if path.is_dir():
            match = list(path.glob(f'{cell}.*v'))
            if len(match) == 0:
                continue
            elif len(match) == 1:
                return match[0]
            else:
                print(f'Found multiple matches for cell={cell} view={view}, returning {match[0]}.')
                return match[0]
    # if we get here, then no matches were found...
    raise Exception(f'Could not find cell={cell} view={view}.')

def get_views(**kwargs):
    return [get_view(cell=cell, view=view) for cell, view in kwargs.items()]
