import pytest

def pytest_addoption(parser):
    parser.addoption(
        '--dump_waveforms', action='store_true', help='Dump waveforms from test.'
    )

    parser.addoption(
        '--board_name', default='ZC702', type=str, help='Name of the FPGA board.'
    )

    parser.addoption(
        '--ser_port', default='/dev/ttyUSB2', type=str, help='USB serial path.'
    )

    parser.addoption(
        '--ffe_length', default=4, type=int, help='Number of FFE coefficients per channel.'
    )

    parser.addoption(
        '--emu_clk_freq', default=5.0e6, type=float, help='Frequency of emulator clock (Hz)'
    )

    parser.addoption(
        '--prbs_test_dur', default=10.0, type=float, help='Length of time of the PRBS emulation test.'
    )

@pytest.fixture
def dump_waveforms(request):
    return request.config.getoption('--dump_waveforms')

@pytest.fixture
def board_name(request):
    return request.config.getoption('--board_name')

@pytest.fixture
def ser_port(request):
    return request.config.getoption('--ser_port')

@pytest.fixture
def ffe_length(request):
    return request.config.getoption('--ffe_length')

@pytest.fixture
def emu_clk_freq(request):
    return request.config.getoption('--emu_clk_freq')

@pytest.fixture
def prbs_test_dur(request):
    return request.config.getoption('--prbs_test_dur')