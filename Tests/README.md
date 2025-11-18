# Tests for GitGulf

Comprehensive XCTest-based test suite covering ANSI utilities, UI rendering with alignment verification, shell execution, repository discovery, command orchestration, CLI parsing, and performance scaling.

## Running tests

```bash
swift test
```

## Test suites (90 tests total)

| Suite | Tests | Purpose |
|-------|-------|----------|
| `ANSIUtilitiesTests` | 4 | String ANSI escape handling and character counting |
| `UIRendererTests` | 6 | Table layout, repository display, color state |
| `UITableAlignmentTests` | 8 | Horizontal/vertical alignment with variable column widths |
| `ShellServiceTests` | 7 | Shell execution: success, errors, timeouts, output size limits |
| `RepositoryTests` | 7 | Repository model: equality, hashing, Sendable conformance |
| `RepositoryManagerTests` | 9 | Discovery: hidden dirs, symlinks, MainActor isolation |
| `GitGulfOrchestrationTests` | 10 | Command orchestration, concurrency, API methods |
| `CLITests` | 12 | Argument parsing and command mapping |
| `PerformanceTests` | 7 | Large datasets (100-1000 repos), rendering/hashing scaling |
| `ErrorHandlingTests` | 20 | Error paths, edge cases, cross-cutting failure scenarios |

## Architecture

- **Library target**: `GitGulfLib` contains all core logic (UI, models, shell, orchestration)
- **Executable target**: `gitgulf` is a thin CLI wrapper around the library
- **Test target**: `GitGulfTests` links against `GitGulfLib`, enabling comprehensive testing

## Test categories

### ANSI & String utilities
- ANSI escape code stripping and character counting for proper terminal rendering

### UI Rendering & Alignment
- Table layout with box-drawing characters (│, ═, ╪)
- Column alignment verification across repos with short/long names
- Dynamic width calculation based on data (1-50+ char names, 1-5 digit numbers)
- Consistent column separators and spacing with mixed data sizes

### Shell Execution
- Command execution with working directory and environment options
- Timeout handling and output size limits
- Error scenarios and exit code propagation

### Repository Model
- Hashable and Equatable conformance (based on name)
- Sendable trait for concurrent use
- State management (branch, ahead, behind, changes)
- Branch name validation for shell injection prevention

### Repository Discovery
- FileManager-based directory scanning
- Hidden directory (`.`) and symlink filtering
- Concurrent initialization with error tolerance
- MainActor isolation for repositories Set

### Command Orchestration
- GitGulf API (status, fetch, pull, rebase, checkout)
- Concurrent task execution per repository
- UI refresh scheduling and timing

### CLI
- Argument parsing for all supported commands
- Command dispatch to GitGulf methods
- Error handling and usage messages

### Performance
- Rendering performance with large repo lists (100-1000 repos)
- Hashing and Set operations at scale
- ANSI stripping efficiency

### Error Handling & Edge Cases
- Repository error handling with invalid paths
- Branch name validation edge cases
- Repository Manager handling of empty/hidden/symlink directories
- UI rendering with zero values and incomplete state
- ANSI color output correctness
- Shell timeout and output size limits
- Repository equality and set deduplication
- Thread safety verification
- Mixed data rendering with extreme values
- Shell environment variable handling
