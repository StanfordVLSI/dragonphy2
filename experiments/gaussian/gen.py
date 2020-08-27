import numpy as np
import random
from pathlib import Path
from argparse import ArgumentParser
from msdsl import MixedSignalModel, VerilogGenerator

MIN_CDF = -6
MAX_CDF = +6
WIDTH = 32

def numstr(i):
    if i < 0:
        return f'm{-i}'
    elif i == 0:
        return '0'
    else:
        return f'p{i}'

def main():
    print('Running model generator...')

    # set random seeds for repeatability
    random.seed(1)
    np.random.seed(2)

    # parse command line arguments
    parser = ArgumentParser()
    parser.add_argument('-o', '--output', type=str, default='build')
    parser.add_argument('--dt', type=float, default=0.1e-6)
    a = parser.parse_args()

    # determine the build directory
    build_dir = Path(a.output).resolve()

    # create the model
    m = MixedSignalModel('model', dt=a.dt, build_dir=build_dir)

    # I/O
    cdf_rst = m.add_digital_input('cdf_rst')
    cdfs = []
    for i in range(MIN_CDF, MAX_CDF+1):
        cdfs.append(m.add_digital_output(f'cdf_{numstr(i)}', width=WIDTH, init=0))
    cdf_tot = m.add_digital_output('cdf_tot', width=WIDTH, init=0)

    # Gaussian noise generation
    gaussian = m.set_gaussian_noise('gaussian')

    # Gaussian noise comparison
    gaussian_lts = []
    for i in range(MIN_CDF, MAX_CDF+1):
        gaussian_lts.append(m.bind_name(f'gaussian_gt_{numstr(i)}', gaussian < i))

    # CDFs
    for cdf, gaussian_lt in zip(cdfs, gaussian_lts):
        m.set_next_cycle(cdf, (cdf+gaussian_lt)[(WIDTH-1):0], rst=cdf_rst)

    # total
    m.set_next_cycle(cdf_tot, (cdf_tot+1)[(WIDTH-1):0], rst=cdf_rst)

    # determine the output filename
    filename = build_dir / f'{m.module_name}.sv'
    print(f'Model will be written to: {filename}')

    # generate the model
    m.compile_to_file(VerilogGenerator(), filename)

if __name__ == '__main__':
    main()
