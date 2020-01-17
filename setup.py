from setuptools import setup

name = 'dragonphy'
version = '0.1.0'

DESCRIPTION = '''\
Open Source PHY v2\
'''

with open('README.md', 'r') as fh:
    LONG_DESCRIPTION = fh.read()

setup(
    name=name,
    version=version,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    long_description_content_type='text/markdown',
    keywords = ['high-speed', 'high speed', 'link', 'high-speed link',
                'high speed link', 'analog', 'mixed-signal', 'mixed signal',
                'generator', 'ic', 'integrated circuit', 'chip'],
    packages=[
        f'{name}'
    ],
    install_requires=[
        'svreal>=0.1.7',
        'msdsl>=0.1.2',
        'anasymod>=0.1.4',
        'pexpect', 
        'pyyaml',
        'numpy',
        'matplotlib'
    ],
    license='Apache License 2.0',
    url=f'https://github.com/StanfordVLSI/{name}',
    author='Stanford University',
    python_requires='>=3.7',
    download_url = f'https://github.com/StanfordVLSI/{name}/archive/v{version}.tar.gz',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)',
        'License :: OSI Approved :: Apache Software License',
        f'Programming Language :: Python :: 3.7'
    ],
    include_package_data=True,
    zip_safe=False
)
