# modified from https://github.com/sgherbst/hslink-emu/blob/master/msemu/server.py
import sys
from pathlib import Path

SERVER_PORT = 57937

class VivadoTCL:
    def __init__(self, prompt='Vivado% '):
        import pexpect
        self.prompt = prompt
        print('Starting Vivado TCL interpreter... ', end='')
        sys.stdout.flush()
        self.proc = pexpect.spawnu('vivado -nolog -nojournal -notrace -mode tcl')
        self.expect_prompt()
        print('done.')

    def expect_prompt(self):
        self.proc.expect(self.prompt)

    def sendline(self, line):
        self.proc.sendline(line)
        self.expect_prompt()
        return self.proc.before

    def source(self, script):
        script = Path(script).resolve()
        self.sendline(f'source {script}')
    
    def refresh_hw_vio(self, name):
        self.sendline(f'refresh_hw_vio {name}')

    def get_vio(self, name):
        before = self.sendline(f'get_property INPUT_VALUE {name}')
        before = before.splitlines()[-1] # get last line
        before = before.strip() # strip off whitespace
        return before

    def set_vio(self, name, value):
        self.sendline(f'set_property OUTPUT_VALUE {value} {name}')
        self.sendline(f'commit_hw_vio {name}')

    def __del__(self):
        print('Sending "exit" to Vivado TCL interpreter... ', end='')
        sys.stdout.flush()
        self.proc.sendline('exit')
        self.proc.wait()
        print('done.')

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
