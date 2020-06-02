import pytest

def pytest_addoption(parser):
    parser.addoption(
        '--dump_waveforms', action='store_true', help='Dump waveforms from test.'
    )
    parser.addoption(
        '--board_name', default='ZC702', type=str, help='Name of the FPGA board.'
    )

@pytest.fixture
def dump_waveforms(request):
    return request.config.getoption('--dump_waveforms')

@pytest.fixture
def board_name(request):
    return request.config.getoption('--board_name')