from setuptools import setup, find_packages

name = 'dragonphy'
version = '0.1.3'

DESCRIPTION = '''\
Open Source PHY v2\
'''

with open('README.md', 'r') as fh:
    LONG_DESCRIPTION = fh.read()

requires_list = [
    # anasymod ecosystem
    'svreal==0.2.7',
    'msdsl==0.3.6.dev2',
    'anasymod==0.3.6.dev4',
    # system-verilog parser
    'svinst==0.1.5',
   # magma ecosystem dependencies
    'fault==3.0.36',
    'magma-lang==2.1.17',
    'coreir==2.0.120',
    'mantle==2.0.10',
    'hwtypes==1.4.3',
    'ast_tools==0.0.30',
    'kratos==0.0.31.1',
   # general requirements
    'pyserial',
    'pexpect',
    'pyyaml',
    'numpy',
    'scipy',
    'matplotlib',
    'sklearn',
    #'pygraphviz',
    'html5lib',
    'lxml',
    'scikit-rf',
    'BeautifulSoup4',
    'justag==0.0.4.5',
    # general requirements with special versions to prevent
    # warnings that clutter pytest output
    'jinja2>=2.11.1',
    'pysmt==0.9.0'
]

setup(
    name=name,
    version=version,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    long_description_content_type='text/markdown',
    keywords = ['high-speed', 'high speed', 'link', 'high-speed link',
                'high speed link', 'analog', 'mixed-signal', 'mixed signal',
                'generator', 'ic', 'integrated circuit', 'chip'],
    packages=find_packages(exclude=['tests']),
    install_requires=requires_list,
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
