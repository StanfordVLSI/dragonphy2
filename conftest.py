import pytest

def pytest_addoption(parser):
    parser.addoption(
        '--dump_waveforms', action='store_true', help='Dump waveforms from test.'
    )

@pytest.fixture
def dump_waveforms(request):
    return request.config.getoption('--dump_waveforms')