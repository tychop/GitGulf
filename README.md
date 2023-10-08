# GitGrove

Manage your forest of Git repositories with ease.

![Logo](img/gitgrove.png)

## Overview

GitGrove is a command-line tool designed to help you manage and navigate through multiple Git repositories with ease. Whether you are dealing with only a handful or a forest of repositories, GitGrove aims to streamline common Git operations like fetching, pulling, and switching branches across multiple repositories, making your development workflow more efficient and effective.

## Features

- **Status**: View the current status of all repositories in a directory.
- **Fetch**: Perform a `git fetch` on all repositories.
- **Pull**: Perform a `git pull` on all repositories.
- **Switch Branch**: Swiftly switch between branches on all repositories.
- **Prune**: Prune all reachable objects from the object databases.
- **Cleanup**: Clean up and optimize your local repositories.

## Installation

Clone the GitGrove repository.

```shell
git clone https://github.com/tychop/gitgrove.git
```

Install GitGrove
```shell
cd gitgrove
pip install .
```

### Requirements

- A modern Python version (3.6+)

### Usage

```
usage: gitgrove COMMAND

optional arguments:
  -s, --status          Show all the repository statuses in the current directory.
  -f, --fetch           Fetch all repositories in the current directory.
  -p, --pull            Pull all repositories in the current directory.
  -pr, --prune          Prunes objects that are no longer reachable from all repositories in the current directory.
  -c, --cleanup         Clean up and optimize the local repositories in the current directory.
  -b, --branch BRANCH   Attempt to switch branch of all repositories to BRANCH.
  -d, --development     Attempt to switch branch of all repositories to development.
```

### Contributing

We welcome contributions to GitGrove! Please see our Contributing Guide for more details.

### License

GitGrove is MIT licensed.

### Acknowledgements

Extend your thanks or acknowledge people or organizations that helped you in working on this project.
