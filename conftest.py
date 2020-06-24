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

@pytest.fixture
def dump_waveforms(request):
    return request.config.getoption('--dump_waveforms')

@pytest.fixture
def board_name(request):
    return request.config.getoption('--board_name')

@pytest.fixture
def ser_port(request):
    return request.config.getoption('--ser_port')