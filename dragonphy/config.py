class CustomConfig:
    def __init__(self, fname='custom.f'):
        self.fname = fname
        self.clear()

    def clear(self):
        with open(self.fname, 'w') as f:
            f.write('')

    def write(self, value):
        with open(self.fname, 'a') as f:
            f.write(value)

    def write_line(self, value, line_ending='\n'):
        self.write(value + line_ending)

    def define(self, name, value):
        self.write_line(f'-define {name}={value}')