# GitRipple

Manage your ocean of Git repositories with ease.

![Logo](img/gitripple.png)

## Overview

GitRipple is a command-line tool designed to help you manage and navigate through multiple Git repositories with ease. Whether you are dealing with only a handful or a wave of repositories, GitRipple aims to streamline common Git operations like fetching, pulling, and switching branches across multiple repositories, making your development workflow more efficient and effective.

## Features

- **Status**: View the current status of all repositories in a directory.
- **Fetch**: Perform a `git fetch` on all repositories.
- **Pull**: Perform a `git pull` on all repositories.
- **Switch Branch**: Swiftly switch between branches on all repositories.
- **Prune**: Prune all reachable objects from the object databases.
- **Cleanup**: Clean up and optimize your local repositories.

## Installation

### Install using pip
```shell
pip install gitripple
```

### Install from this repo
Clone the gitripple repository and run pip install on it:.
```shell
git clone https://github.com/tychop/gitripple.git
cd gitripple
pip install .
```

### Requirements

- A modern Python version (3.6+)

### Usage

```
gitripple COMMAND

or use one of the shortcuts:
    gr COMMAND, grs, grf, grp, grpr, grc, grb BRANCH, grd

Commands:
    -s, --status       : Show all the repository statuses.
    -f, --fetch        : Fetch all repositories.
    -p, --pull         : Pull all repositories.
    -pr, --prune       : Prunes objects that are no longer reachable.
    -c, --cleanup      : Clean up and optimize the local repositories.
    -b, --branch BRANCH: Switch all repositories to a specified branch.
    -d, --development  : Switch all repositories to the development branch.

Shortcuts:
    gr        : Same as gitripple.
    grs       : Show all the repository statuses.
    grf       : Fetch all repositories.
    grp       : Pull all repositories.
    grpr      : Prunes objects that are no longer reachable.
    grc       : Clean up and optimize the local repositories.
    grb BRANCH: Switch all repositories to a specified branch.
    grd       : Switch all repositories to the development branch.
```

### Contributing

We welcome contributions to GitGrove! Please see our Contributing Guide for more details.

### License

GitGrove is MIT licensed.

### Acknowledgements

Extend your thanks or acknowledge people or organizations that helped you in working on this project.
