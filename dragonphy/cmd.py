import inspect
from argparse import ArgumentParser

class CmdLineParser(ArgumentParser):
    def __init__(self):
        super().__init__()
        self.add_argument('--nosim', action='store_true')
        self.add_argument('--stats', action='store_true')
        self.add_argument('--calib', action='store')


        # parse args and create kwargs dict
        args = self.parse_args()
        self.command_line_args = {
            'nosim': args.nosim,
            'stats': args.stats,
            'calib': args.calib
        }

    def call_with_args(self, method):
        method_arg_names = inspect.getfullargspec(method)[0]
        kwargs_to_use = {}

        for method_arg_name in method_arg_names:
            if method_arg_name in self.command_line_args:
                kwargs_to_use[method_arg_name] = self.command_line_args[method_arg_name]

        method(**kwargs_to_use)
