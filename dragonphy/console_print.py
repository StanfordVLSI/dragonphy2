# Terminal formatting codes adapted from http://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html#8-colors

COLOR_CODES = dict(
    black = '\x1b[30m',
    red = '\x1b[31m',
    green = '\x1b[32m',
    yellow = '\x1b[33m',
    blue = '\x1b[34m',
    magenta = '\x1b[35m',
    cyan = '\x1b[36m',
    white = '\x1b[37m',
    bright = '\x1b[1m',
    reset = '\x1b[0m',
)

def cprint(s, *args, color=None, bold=None, **kwargs):
    # set defaults
    if bold is None:
        bold = color is not None

    # build up the string to print
    to_print = f'{s}'
    if bold:
        to_print = COLOR_CODES['bright']  + to_print
    if color is not None:
        to_print = COLOR_CODES[color.lower()] + to_print
    if bold or color is not None:
        to_print += COLOR_CODES['reset']

    # print the string
    print(to_print, *args, **kwargs)

def cprint_announce(title, text, color=None, bold=None):
    cprint(title, color=color, bold=bold, end='')
    print(text)

def cprint_block_start(title, color=None, bold=None):
    cprint(f'<{title}>', color=color, bold=bold)

def cprint_block_end(title, color=None, bold=None):
    cprint(f'</{title}>', color=color, bold=bold)

def cprint_block(str_list, title, color=None, bold=None):
    # don't print out anything if the string list has zero length
    if len(str_list) == 0:
        return

    # otherwise print out the text with the start and end indicated
    cprint_block_start(title, color=color, bold=bold)
    for s in str_list:
        print(str(s).rstrip())
    cprint_block_end(title, color=color, bold=bold)