# TODO: replace with programmatic construction of filesets

class AnasymodSourceConfig:
    def __init__(self):
        self.verilog_sources = []
        self.verilog_headers = []
        self.xci_files = []
        self.xdc_files = []
        self.defines = []

    def add_verilog_sources(self, file_list, fileset='default'):
        self.verilog_sources += [(file_, fileset) for file_ in file_list]

    def add_verilog_headers(self, header_list, fileset='default'):
        self.verilog_headers += [(header, fileset) for header in header_list]

    def add_xci_files(self, xci_files, fileset='default'):
        self.xci_files += [(xci_file, fileset) for xci_file in xci_files]

    def add_xdc_files(self, xdc_files, fileset='default'):
        self.xdc_files += [(xdc_file, fileset) for xdc_file in xdc_files]

    def add_defines(self, defines, fileset='default'):
        for key, val in defines.items():
            self.defines += [(key, val, fileset)]

    def write_to_file(self, fname):
        with open(fname, 'w') as f:
            for file_, fileset in self.verilog_sources:
                f.write(f'VerilogSource(files="{file_}", fileset="{fileset}")\n')

            for file_, fileset in self.verilog_headers:
                f.write(f'VerilogHeader(files="{file_}", fileset="{fileset}")\n')

            for key, val, fileset in self.defines:
                if val is None:
                    f.write(f'Define(name="{key}", fileset="{fileset}")\n')
                else:
                    f.write(f'Define(name="{key}", value="{val}", fileset="{fileset}")\n')

            for file_, fileset in self.xdc_files:
                f.write(f'XDCFile(files="{file_}", fileset="{fileset}")\n')

            for file_, fileset in self.xci_files:
                f.write(f'XCIFile(files="{file_}", fileset="{fileset}")\n')
