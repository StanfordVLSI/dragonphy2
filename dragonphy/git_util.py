import subprocess


def get_git_is_clean():
    result = subprocess.run(['git', 'status', '--porcelain'], capture_output=True)
    print(result.stdout)
    if result.stdout == '':
        return True
    else:
        return False


def get_git_hash_short():
    result = subprocess.run(['git', 'rev-parse', 'HEAD'], capture_output=True)
    # get output
    git_hash_str = result.stdout
    # shorten to 7 characters (28 bits)
    git_hash_short_str = git_hash_str[:7]
    # convert short hash to an int
    git_hash_short = int(git_hash_short_str, 16)
    # return int
    return git_hash_short
