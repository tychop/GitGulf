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

## Installation

### Install using hoembrew

```shell
brew tap tychop/homebrew-gitgulf
brew install gitgulf
```

### Install from this repo

Clone the gitgulf repository and run `swift build -c release`:

```shell
git clone https://github.com/tychop/gitgulf.git
cd gitgulf
swift build -c release
```
The binary will be located at: `gitgulf/.build/release/gitgulf`

### Requirements

- Homebrew

### **Usage:**

```bash
gitgulf COMMAND
```

Use `gitgulf` without any arguments to see all the options.

Choose from the following commands:

```
`status`        : Show all repository statuses.
`fetch`         : Fetch all repositories.
`pull`          : Pull all repositories.
`master`        : Switch all repositories to the 'main' branch.
`development`   : Switch all repositories to the 'development' branch.
`-b <branch>    : Switch all repositories to the specified branch.
```

### Abbreviated Commands:

Instead of the `gitgulf COMMAND` syntax, use abbreviated commands for quicker operations:

```
`ggs`        : Show all the repository statuses.
`ggf`        : Fetch all repositories.
`ggp`        : Pull all repositories.
`ggm`        : Switch all repositories to the 'master' branch.
`ggd`        : Switch all repositories to the 'development' branch.
`ggb BRANCH` : Switch all repositories to the specified BRANCH.
```

### License

GitGulf is MIT licensed.
