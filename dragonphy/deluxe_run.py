# modified from https://github.com/leonardt/fault/blob/master/fault/subprocess_run.py

from pathlib import Path
from subprocess import Popen, PIPE, CompletedProcess
import shlex

from .console_print import cprint_block_start, cprint_block_end, cprint_announce

def print_lines(fd, name, color='magenta'):
    text = ''

    for line in fd:
        if text == '':
            cprint_block_start(name, color=color)
        print(line.rstrip())
        text += line

    if text != '':
        cprint_block_end(name, color=color)

    return text

def deluxe_run(args, cwd, err_str=None):
    # set defaults
    if err_str is None:
        err_str = []

    # handle single error string or list of error strings
    if not isinstance(err_str, list):
        err_str = list(err_str)

    # make build directory if needed
    if cwd is not None:
        cwd = Path(cwd)
        cwd.mkdir(exist_ok=True)

    # make sure all arguments are strings
    args = [f'{arg}' for arg in args]

    # print out the command being run
    print_args = ' '.join([shlex.quote(arg) for arg in args])
    cprint_announce('Running command: ', print_args, color='cyan')

    # run the command
    with Popen(args, cwd=cwd, stdout=PIPE, stderr=PIPE, bufsize=1,
               universal_newlines=True) as p:
        # get output from command
        stdout = print_lines(p.stdout, 'STDOUT')
        stderr = print_lines(p.stderr, 'STDERR')
        returncode = p.wait()

        # check the return code
        assert returncode == 0

        # look for known error strings
        for e in err_str:
            assert e not in stdout, f'Found "{e}" in STDOUT.'
            assert e not in stderr, f'Found "{e}" in STDERR.'

    return CompletedProcess(args=args, returncode=returncode,
                            stdout=stdout, stderr=stderr)
