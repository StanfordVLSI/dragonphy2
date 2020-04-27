# DragonPHY

[![BuildKite Status](https://badge.buildkite.com/46976365e67cd49a5ef6402136255426d399b17039869a1efd.svg?branch=master)](https://buildkite.com/stanford-aha/dragonphy2)
[![License:Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Code Coverage](https://codecov.io/gh/StanfordVLSI/dragonphy2/branch/master/graph/badge.svg)](https://codecov.io/gh/StanfordVLSI/dragonphy2)

DragonPHY is the second design in the Open Source PHY project at Stanford.

## Installation

1. Clone the repository.
```shell
> git clone https://github.com/StanfordVLSI/dragonphy2.git
```
2. Go into the top-level folder
```shell
> cd dragonphy2
```
3. Install the Python package associated with this project.
```shell
> pip install -e .
```

## Upgrading

To upgrade to the latest version of DragonPHY:
1. Pull changes from the **master** branch.
```shell
> git pull origin master
```
2. Re-install the Python package (since dependencies may have changed):
```shell
> pip install -e .
```

## Running tests

1. First install **pytest** if it is not already installed:
```shell
> pip install pytest
```
2. Then, in the top directory of the project, run the tests in the **tests** directory:
```shell
> pytest tests
```
