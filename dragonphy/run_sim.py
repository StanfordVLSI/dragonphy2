from pathlib import Path
from .deluxe_run import deluxe_run

def run_sim(srcs=None, libs=None, timescale='1s/1fs',
            inc_dirs=None, top=None, cwd=None, defs=None):
    # set defaults
    if srcs is None:
        srcs = []
    if libs is None:
        libs = []
    if inc_dirs is None:
        inc_dirs = []
    if defs is None:
        defs = []

    # convert to lists if needed
    if not isinstance(srcs, list):
        srcs = list(srcs)
    if not isinstance(libs, list):
        libs = list(libs)
    if not isinstance(inc_dirs, list):
        inc_dirs = list(inc_dirs)
    if not isinstance(defs, list):
        defs = list(defs)

    srcs = [Path(src).resolve() for src in srcs]
    libs = [Path(lib).resolve() for lib in libs]
    inc_dirs = [Path(d).resolve() for d in inc_dirs]

    # construct the command
    args = []
    args += ['xrun']
    if timescale is not None:
        args += ['-timescale', '1s/1fs']
    if top is not None:
        args += ['-top', f'{top}']
    for inc_dir in inc_dirs:
        args += [f'+incdir+{inc_dir}']
    for src in srcs:
        args += [f'{src}']
    for lib in libs:
        args += ['-v', f'{lib}']
    for def_ in defs:
        if not isinstance(def_, str):
            args += [f'+define+{def_[0]}={def_[1]}']
        else:
            args += [f'+define+{def_}']

    # run the simulation
    err_str = ['ERROR', 'FATAL']
    deluxe_run(args, cwd=cwd, err_str=err_str)
