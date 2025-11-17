
<p align="center">
  <img src="img/gitgulf_640.png" alt="GitGulf Logo" width="320">
</p>

## Overview

GitGulf is a command-line tool designed to help you manage and navigate through multiple Git repositories with ease. Whether you are dealing with only a handful or a full collection of repositories, GitGulf aims to streamline common Git operations like fetching, pulling, and switching branches across multiple repositories, making your development workflow more efficient and effective.

### Latest Release: v0.2.1

**Major security and reliability improvements:**
- ✅ Fixed command injection vulnerability in branch names
- ✅ Improved thread safety and race condition fixes
- ✅ Graceful error recovery (no more crashes on repo failures)
- ✅ Better git output parsing for locale independence
- ✅ Proper error output routing (stderr compliance)
- ✅ TTY-aware ANSI code handling

&nbsp;

Gif showing `ggs` (status), `ggf` (fetch), & `ggp` (pull):

<p align="left">
  <img src="img/gitgulf.gif" width="540">
</p>

## Features

- **Status**: View the current status of all repositories in a directory.
- **Fetch**: Perform a `git fetch` on all repositories.
- **Pull**: Perform a `git pull` on all repositories.
- **Switch Branch**: Swiftly switch between branches on all repositories.

## Installation

### Install using Homebrew

```shell
brew tap tychop/homebrew-gitgulf
brew install gitgulf
```

### Install from the Repository

Clone the gitgulf repository and build the project using Swift:

```shell
git clone https://github.com/tychop/gitgulf
cd gitgulf
swift build -c release
```

The binary will be located at: `gitgulf/.build/release/gitgulf`

### Requirements

- **Swift**: 5.10 or later
- **macOS**: 12.0 or later (for modern async/await support)
- **Git**: Any recent version
- **Homebrew**: (optional, for installation)

## Usage

### Basic Commands

Run the following command pattern for basic usage:

```shell
gitgulf COMMAND
```

Use `gitgulf` without any arguments to see all the available options.

Available commands:

```
status        : Show all repository statuses.
fetch         : Fetch all repositories.
pull          : Pull all repositories.
master        : Switch all repositories to the 'master' branch.
development   : Switch all repositories to the 'development' branch.
-b <branch>   : Switch all repositories to the specified branch.
```

### Abbreviated Commands

For quicker operations, use the abbreviated commands:

```
ggs        : Show all the repository statuses.
ggf        : Fetch all repositories.
ggp        : Pull all repositories.
ggm        : Switch all repositories to the 'master' branch.
ggd        : Switch all repositories to the 'development' branch.
ggb BRANCH : Switch all repositories to the specified BRANCH.
```

## Documentation

- **[README.md](README.md)**: This file with overview and usage instructions

## Security

GitGulf v0.2.0 includes comprehensive security improvements:

- ✅ Input validation to prevent command injection
- ✅ Thread-safe repository state management
- ✅ Proper error handling without silent failures
- ✅ Validated git command execution

For security concerns, please report to the GitHub repository.

## License

GitGulf is MIT licensed.
