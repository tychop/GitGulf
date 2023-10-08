from setuptools import setup, find_packages

setup(
    name='gitgrove',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[],
    entry_points={
        'console_scripts': [
            'gitgrove = src.main:main',
            'gg = src.main:main',
            'ggs = src.main:main_s',
            'ggf = src.main:main_f',
            'ggp = src.main:main_p',
            'ggpr = src.main:main_pr',
            'ggc = src.main:main_c',
            'ggb = src.main:main_b',
            'ggd = src.main:main_d'
        ],
    },
    author='Tycho Pandelaar',
    author_email='fairest.09trough@icloud.com',
    description='A CLI tool for managing multiple Git repositories collectively.',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/tychop/gitgrove',
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)
