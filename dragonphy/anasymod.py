class AnasymodSourceConfig:
    def __init__(self):
        self.verilog_sources = []
        self.verilog_headers = []
        self.xci_files = []
        self.xdc_files = []

    def add_verilog_sources(self, file_list):
        self.verilog_sources += file_list

    def add_verilog_headers(self, header_list):
        self.verilog_headers += header_list

    def add_xci_files(self, xci_files):
        self.xci_files += xci_files

    def add_xdc_files(self, xdc_files):
        self.xdc_files += xdc_files

    def write_to_file(self, fname):
        with open(fname, 'w') as f:
            vsrcs = [f'{vsrc}' for vsrc in self.verilog_sources]
            f.write(f'VerilogSource(files={vsrcs}, fileset="fpga")\n')

            vhdrs = [f'{vhdr}' for vhdr in self.verilog_headers]
            f.write(f'VerilogHeader(files={vhdrs}, fileset="fpga")\n')

            xdcs = [f'{xdc}' for xdc in self.xdc_files]
            f.write(f'XDCFile(files={xdcs}, fileset="fpga")\n')

            xcis = [f'{xci}' for xci in self.xci_files]
            f.write(f'XCIFile(files={xcis}, fileset="fpga")\n')
