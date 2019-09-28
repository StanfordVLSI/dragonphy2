from setuptools import setup

setup(
    name='dragonphy',
    version='0.0.1',
    description='Open Source PHY v2',
    scripts=[],
    packages=[
        'dragonphy',
    ],
    install_requires=[
        'pexpect'
    ],
    license='Apache License 2.0',
    url='https://github.com/StanfordVLSI/dragonphy',
    author='Stanford University',
    python_requires='>=3.7',
)
