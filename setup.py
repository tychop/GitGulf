from setuptools import setup, find_packages

setup(
    name='gitripple',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[],
    entry_points={
        'console_scripts': [
            'gitripple = src.main:main',
            'gr = src.main:main',
            'grs = src.main:main_s',
            'grf = src.main:main_f',
            'grp = src.main:main_p',
            'grpr = src.main:main_pr',
            'grc = src.main:main_c',
            'grb = src.main:main_b',
            'grd = src.main:main_d'
        ],
    },
    author='Tycho Pandelaar',
    author_email='tychop@me.com',
    description='A CLI tool for managing multiple Git repositories collectively.',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/tychop/gitripple',
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)
