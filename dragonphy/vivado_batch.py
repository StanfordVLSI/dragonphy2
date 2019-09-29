from pathlib import Path
from .deluxe_run import deluxe_run


def vivado_batch(script=None, cwd=None):
    # find path to script
    script = Path(script).resolve()

    # construct the command
    args = []
    args += ['vivado']
    args += ['-nolog']
    args += ['-nojournal']
    args += ['-mode', 'batch']
    args += ['-source', f'{script}']

    err_str = ['CRITICAL WARNING', 'ERROR', 'FATAL']

    deluxe_run(args, cwd=cwd, err_str=err_str)
