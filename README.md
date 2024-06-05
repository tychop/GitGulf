<p align="center">
  <img src="img/gitgulf_640.png" alt="GitGulfLogo" width="320">
</p>

## Overview

GitGulf is a command-line tool designed to help you manage and navigate through multiple Git repositories with ease. Whether you are dealing with only a handful or a full collection of repositories, GitGulf aims to streamline common Git operations like fetching, pulling, and switching branches across multiple repositories, making your development workflow more efficient and effective.

Gif showing ggs (status), ggf (fetch) & ggp (pull):
<p align="left">
  <img src="img/gitgulf.gif" width="540">
</p>

## Features

-   **Status**: View the current status of all repositories in a directory.
-   **Fetch**: Perform a `git fetch` on all repositories.
-   **Pull**: Perform a `git pull` on all repositories.
-   **Switch Branch**: Swiftly switch between branches on all repositories.
-   **Prune**: Prune all reachable objects from the object databases.
-   **Cleanup**: Clean up and optimize your local repositories.

## Installation

### Install using pip

```shell
pip install gitgulf
```

### Install from this repo

Clone the gitgulf repository and run pip install on it:.

```shell
git clone https://github.com/tychop/gitgulf.git
cd gitgulf
pip install .
```

### Requirements

-   A modern Python version (3.6+)

### **Usage:**

```bash
gitgulf COMMAND
```

Use `gitgulf` without any arguments to see all the options.

Choose from the following commands:

```
`-s, --status`        : Show all repository statuses.
`-f, --fetch`         : Fetch all repositories.
`-p, --pull`          : Pull all repositories.
`-b, --branch` BRANCH : Switch all repositories to the specified BRANCH.
`-m, --main`          : Switch all repositories to the 'main' branch.
`-d, --development`   : Switch all repositories to the 'development' branch.
`-pr, --prune`        : Prune objects no longer reachable from all repositories.
`-c, --cleanup`       : Clean up and optimize local repositories.
```

### Abbreviated Commands:

Instead of the `gitgulf COMMAND` syntax, use abbreviated commands for quicker operations:

```
`ggs`        : Show all the repository statuses.
`ggf`        : Fetch all repositories.
`ggp`        : Pull all repositories.
`ggb BRANCH` : Switch all repositories to the specified BRANCH.
`ggm`        : Switch all repositories to the 'main' branch.
`ggd`        : Switch all repositories to the 'development' branch.
`ggpr`       : Prune objects that are no longer reachable from all repositories.
`ggc`        : Clean up and optimize the local repositories.
```

### Contributing

We welcome contributions to GitGulf! Please see our Contributing Guide for more details.

### License

GitGulf is MIT licensed.
