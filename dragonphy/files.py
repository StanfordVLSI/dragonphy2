import os
from pathlib import Path

TOP_DIR = Path(__file__).resolve().parent.parent

def get_file(path):
    return Path(TOP_DIR, path)

def get_dir(path):
    # alias for get_file
    return get_file(path)

def get_files(*args):
    return [get_file(path) for path in args]

def get_files_arr(paths):
    return [get_file(path) for path in paths]

def get_dirs(*args):
    # alias for get_files
    return get_files(*args)

def get_mlingua_dir():
    return Path(os.environ['mLINGUA_DIR']).resolve()