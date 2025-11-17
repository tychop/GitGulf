# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build & Run Commands

### Building the Project
- **Debug build**: `swift build`
- **Release build**: `swift build -c release`
- **Binary location (release)**: `.build/release/gitgulf`

### Running the Tool
```shell
# From the repository root after building:
.build/release/gitgulf [command]

# Or after installing via Homebrew:
gitgulf [command]
ggs|ggf|ggp|ggm|ggd|ggb [args]  # Abbreviated commands
```

### Testing & Development
- Currently no formal test suite; manual testing by running commands against repositories
- Use `swift build` to compile and check for syntax errors during development

## Code Architecture

### High-Level Structure
GitGulf is a command-line utility that discovers Git repositories in the current directory and executes Git commands on them in parallel using Swift async/await. The tool displays real-time, color-coded status updates as operations complete.

### Key Components

**Main Entry Point** (`Sources/main.swift`)
- Parses command-line arguments (status, fetch, pull, development, master, -b <branch>, --version)
- Instantiates `GitGulf` and delegates to appropriate async method
- Always prints a leading newline before output

**Core Engine** (`Sources/GitGulf/GitGulf.swift`)
- `GitCommand` enum: Defines the four operation types (status, fetch, pull, checkout)
- `GitGulf` class: Orchestrates repository discovery, parallel execution, and UI updates
- Uses `@MainActor` for thread-safe UI rendering
- Employs `withTaskGroup` to execute Git commands concurrently across all discovered repositories
- Real-time cursor manipulation to update the display as each repository completes its operation

**Repository Discovery & Management** (`Sources/GitGulf/RepositoryManager.swift`)
- `RepositoryManager`: Discovers all subdirectories with a `.git` folder in the current working directory
- Loads repository metadata (branch, commit counts, changes) in parallel
- Maintains a `Set<Repository>` of discovered repositories

**Repository Model** (`Sources/Model/Repository.swift`)
- `Repository` class: Represents a single Git repository with properties: name, path, branch, ahead, behind, changes, and colorState
- Implements `Hashable` for use in sets
- Methods: `status()`, `fetch()`, `pull()`, `checkout(branch:)` that execute Git commands via `Shell`
- Each Git operation ends with `finish()` which calls `status()` to refresh metadata

**Shell Execution** (`Sources/Services/ShellService.swift`)
- `Shell` struct: Low-level wrapper around `Process` for executing shell commands
- Uses `/usr/bin/env` as the executable (allows PATH resolution)
- Async execution with `withCheckedThrowingContinuation`
- Returns both stdout/stderr combined and the exit status
- Trims whitespace from output

**UI Rendering** (`Sources/UI/UIRenderer.swift`)
- `UIRenderer` class: Formats repository status data into a colored, aligned table
- Dynamically calculates column widths based on content
- Color coding:
  - **Purple**: Commits ahead of remote
  - **Red**: Commits behind remote
  - **Cyan**: Uncommitted changes
  - **Bright green**: Repository is clean
  - **Grey**: Repository still loading (colorState = false)
- Uses ANSI escape codes for coloring and formatting
- Supports repository names with ellipsis padding for display truncation

### Data Flow

1. User runs `gitgulf [command]`
2. `main.swift` parses arguments and calls `GitGulf.<method>()`
3. `GitGulf` calls `RepositoryManager.loadRepositories()` to discover repos and fetch initial status
4. For each command, `GitGulf.run(gitCommand:)` creates a task group that executes the command in parallel on each repository
5. As each repository completes, `updateUI()` is called on the main thread, rendering an updated table and moving the cursor up to replace the previous frame
6. Final frame is rendered without cursor movement at the end
7. Execution time is printed

### concurrency Model
- Main program uses top-level `async { }` to enable async/await
- Repository discovery: parallel tasks via `withTaskGroup`
- Command execution: parallel tasks via `withTaskGroup`
- UI updates: synchronized via `@MainActor` to prevent race conditions
- Shell commands: async with continuation-based `Process` execution

## Development Guidelines

- **Use tabs for indentation** (configured in Project rules)
- Keep `Repository` and `GitGulf` focused on orchestration; business logic for Git operations resides in `Repository`
- All user-facing output flows through `UIRenderer` to maintain consistent formatting
- When adding new Git operations, define a new `GitCommand` case and add a corresponding `Repository` method
- Terminal cursor manipulation (ANSI escape codes) is centralized in `GitGulf.moveCursorUp(_:)`
- Error handling: Git command failures cause `exit(1)` to be called; consider allowing partial failures in future versions
