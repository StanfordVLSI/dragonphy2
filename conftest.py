# content of conftest.py

import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--runslow", action="store_true", default=False, help="run slow tests"
    )
    
    parser.addoption(
        "--runwip", action="store_true", default=False, help="run tests that are currently a work in progress"
    )


def pytest_configure(config):
    config.addinivalue_line("markers", "slow: mark test as slow to run")
    config.addinivalue_line("markers", "wip: mark test as work-in-progress")

def pytest_collection_modifyitems(config, items):
    skip_slow = pytest.mark.skip(reason="need --runslow option to run")
    skip_wip = pytest.mark.skip(reason="need --runwip option to run")
    
    for item in items:
        if config.getoption("--runslow") and "slow" in item.keywords:
            item.add_marker(skip_slow)
        elif config.getoption("--runwip") and "wip" in item.keywords:
            item.add_marker(skip_wip)
