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
    'svreal==0.2.2',
    'msdsl==0.2.4',
    'anasymod==0.2.2',
    # system-verilog parser
    'svinst==0.1.1',
    # magma ecosystem dependencies
    'fault==3.0.11',
    'magma-lang==2.0.32',
    'coreir==2.0.63',
    'mantle==2.0.7',
    'hwtypes==1.3.6',
    'ast_tools==0.0.14',
    'kratos==0.0.27',
    # general requirements
    'pexpect',
    'pyyaml',
    'numpy',
    'scipy',
    'matplotlib',
    'sklearn',
    'pygraphviz',
    'html5lib',
    'lxml',
    'BeautifulSoup4',
    'justag==0.0.2.9',
    # general requirements with special versions to prevent
    # warnings that clutter pytest output
    'jinja2>=2.11.1',
    'pysmt>=0.8.1.dev93'
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
