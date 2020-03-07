from setuptools import setup, find_packages

name = 'dragonphy'
version = '0.1.1'

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
    packages=find_packages(exclude=['tests']),
    install_requires=[
        'pexpect', 
        'pyyaml',
        'numpy',
        'matplotlib',
        # sv-parser
        'svinst==0.0.8',
        # anasymod ecosystem
        'svreal==0.2.0',
        'msdsl==0.1.7',
        'anasymod==0.2.1',
        # magma ecosystem dependencies
        'fault==3.0.7',
        'magma-lang==2.0.21',
        'coreir==2.0.61',
        'mantle==2.0.7',
        'hwtypes==1.3.5',
        'pysmt==0.8.1.dev93'
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
