# modified from https://github.com/sgherbst/hslink-emu/blob/master/msemu/server.py
import sys
import time
from numbers import Number
from pathlib import Path
from .console_print import cprint_block, cprint_block_start, cprint_block_end

SERVER_PORT = 57937

class VivadoTCL:
    def __init__(self, cwd=None, prompt='Vivado% ', err_strs=None, debug=False, mock=False):
        # set defaults
        if err_strs is None:
            err_strs = ['ERROR', 'FATAL']

        # save settings
        self.cwd = cwd
        self.prompt = prompt
        self.debug = debug
        self.err_strs = err_strs
        self.mock = mock

        # return at this point if in "mock" mode
        if self.mock:
            print('Creating a VivadoTCL object in "mock" mode.')
            return

        # start the interpreter
        from pexpect import spawnu
        print('Starting Vivado TCL interpreter.')
        sys.stdout.flush()
        cmd = 'vivado -nolog -nojournal -notrace -mode tcl'
        self.proc = spawnu(command=cmd, cwd=cwd)
        
        # wait for the prompt
        self.expect_prompt(timeout=300)

    def expect_prompt(self, timeout=float('inf')):
        before = ''
        start_time = time.time()
        lines_recv = 0
        while (time.time() - start_time) < timeout:
            remaining = timeout - (time.time() - start_time)
            if remaining == float('inf'):
                remaining = None
            index = self.proc.expect(['\n', self.prompt], timeout=remaining)
            if index == 0:
                before += self.proc.before + '\n'
                lines_recv += 1
                if self.debug:
                    if lines_recv == 2:
                        cprint_block_start('RECV', 'cyan')
                    if lines_recv >= 2:
                        print(self.proc.before)
            else:
                break
        if self.debug and lines_recv >= 2:
            cprint_block_end('RECV', 'cyan')
        return before

    def sendline(self, line, timeout=float('inf')):
        if self.mock:
            #print(f'Would send the TCL command "{line}".')
            print(f'{line}')
            return None

        if self.debug:
            cprint_block([line], title='SEND', color='magenta')

        self.proc.sendline(line)
        before = self.expect_prompt(timeout=timeout)

        # make sure that there were no errors
        for err_str in self.err_strs:
            if err_str in before:
                raise Exception(f'Found {err_str} in output from Vivado.')

        return before

    def source(self, script, timeout=float('inf')):
        script = Path(script).resolve()
        self.sendline(f'source {script}', timeout=timeout)
    
    def refresh_hw_vio(self, name, timeout=30):
        self.sendline(f'refresh_hw_vio {name}', timeout=timeout)

    def get_vio(self, name, timeout=30):
        before = self.sendline(f'get_property INPUT_VALUE {name}', timeout=timeout)
        if self.mock:
            return 0

        before = before.splitlines()[-1] # get last line
        before = before.strip() # strip off whitespace
        return before

    def set_vio(self, name, value, timeout=30):
        self.sendline(f'set_property OUTPUT_VALUE {value} {name}', timeout=timeout)
        self.sendline(f'commit_hw_vio {name}')

    def set_var(self, name, value):
        self.sendline(f'set {name} {self.tcl_val(value)}')

    @classmethod
    def tcl_val(cls, value):
        if isinstance(value, (list, tuple)):
            return '[list ' + ' '.join(cls.tcl_val(elem) for elem in value) + ']'
        elif isinstance(value, str):
            return '"' + value + '"'
        elif isinstance(value, Path):
            return cls.tcl_val(str(value))
        elif isinstance(value, Number):
            return str(value)
        else:
            raise Exception(f"Don't know how to convert to a TCL literal: {value}.")

    def __del__(self):
        if self.mock:
            return

        print('Sending "exit" to Vivado TCL interpreter.')
        self.proc.sendline('exit')

def get_vivado_tcl_client():
    import xmlrpc.client
    return xmlrpc.client.ServerProxy(f'http://localhost:{SERVER_PORT}')

def main():
    # modified from https://docs.python.org/3.7/library/xmlrpc.server.html?highlight=xmlrpc
    print(f'Launching Vivado TCL server on port {SERVER_PORT}.')

    from xmlrpc.server import SimpleXMLRPCServer
    from xmlrpc.server import SimpleXMLRPCRequestHandler

    # Restrict to a particular path.
    class RequestHandler(SimpleXMLRPCRequestHandler):
        rpc_paths = ('/RPC2',)

    # Instantiate TCL evaluator
    tcl = VivadoTCL()

    # Create server
    with SimpleXMLRPCServer(('localhost', SERVER_PORT),
                            requestHandler=RequestHandler,
                            allow_none=True) as server:
        server.register_introspection_functions()

        # list of functions available to the client
        server.register_function(tcl.sendline)
        server.register_function(tcl.source)
        server.register_function(tcl.refresh_hw_vio)
        server.register_function(tcl.set_vio)
        server.register_function(tcl.get_vio)

        # program not progress past this point unless
        # Ctrl-C or similar is pressed.
        server.serve_forever()

if __name__ == '__main__':
    main()
