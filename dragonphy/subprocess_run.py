# general imports
import sys
import shlex
import re
from subprocess import Popen, PIPE, STDOUT


def error_detected(text, err_str):
    # Returns True if the error pattern "err_str" is detected in "text"
    # "err_str" can be a one of several things:
    # 1. A single string.
    # 2. A list of strings.  The error is considered to be found if any of the
    #    strings appear in the given text.
    # 3. A regular expression Pattern (re.Pattern).  The given text is searched
    #    for any occurrence of this pattern.
    # from: https://github.com/leonardt/fault/blob/master/fault/subprocess_run.py
    if isinstance(err_str, str):
        return err_str in text
    elif isinstance(err_str, list):
        return any(elem in text for elem in err_str)
    elif isinstance(err_str, re.Pattern):
        return err_str.match(text) is not None
    else:
        raise Exception(f'Invalid err_str: {err_str}.')


def tee_output(fd, err_str=None):
    # prints lines from the given file descriptor while checking for errors
    # returns a flag indicating whether an error was detected
    # modified from: https://github.com/leonardt/fault/blob/master/fault/subprocess_run.py

    found_err = False
    for line in fd:
        # display line
        print(line, end='')

        # check line for errors
        if err_str is not None:
            if error_detected(text=line, err_str=err_str):
                found_err = True

    # Return flag indicating whether an error was found
    return found_err


def subprocess_run(args, cwd=None, wait=True, err_str=None):
    # run a command and optionally check for error strings in the output
    # modified from: https://github.com/leonardt/fault/blob/master/fault/subprocess_run.py

    # print command string with proper escaping so that
    # a user can simply copy and paste the command to re-run it
    cmd_str = ' '.join(shlex.quote(arg) for arg in args)
    print(f"Checking return code of subprocess call: {cmd_str}")

    # run the command
    if wait:
        with Popen(args, cwd=cwd, stdout=PIPE, stderr=STDOUT, bufsize=1,
                   universal_newlines=True) as p:
            # print output while checking for errors
            found_err = tee_output(fd=p.stdout, err_str=err_str)

            # get return code and check result if desired
            returncode = p.wait()

            # check return code
            assert returncode == 0, f'Exited with non-zero code: {returncode}'

            # check for an error in the output text
            if found_err:
                raise Exception(f'Found {err_str} in output of subprocess.')
    else:
        Popen(args=args, cwd=cwd, stdout=sys.stdout, stderr=sys.stdout)