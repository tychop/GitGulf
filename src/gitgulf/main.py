import sys
import time
from gitgulf.repository_manager import GitRepoManager


def show_usage():
    """
    Prints the usage information.
    """
    print("""
  Usage:
      `gitgulf COMMAND`,
      or use one of the Abbreviated Commands described below.

  Commands:
      -s,  --status        : Show all the repository statuses.
      -f,  --fetch         : Fetch all repositories.
      -p,  --pull          : Pull all repositories.
      -b,  --branch BRANCH : Switch all repositories to the specified BRANCH.
      -m,  --main          : Switch all repositories to the 'main' branch.
      -d,  --development   : Switch all repositories to the 'development' branch.
      -pr, --prune         : Prune objects that are no longer reachable from all local repositories.
      -c,  --cleanup       : Clean up and optimize the local repositories.
 
  Abbreviated Commands:
    Instead of the full `gitgulf COMMAND` syntax, you can use abbreviated commands for quicker operations:
      `ggs`        : Show all the repository statuses.
      `ggf`        : Fetch all repositories.
      `ggp`        : Pull all repositories.
      `ggb BRANCH` : Switch all repositories to the specified BRANCH.
      `ggm`        : Switch all repositories to the 'main' branch.
      `ggd`        : Switch all repositories to the 'development' branch.
      `ggpr`       : Prune objects that are no longer reachable from all local repositories.
      `ggc`        : Clean up and optimize the local repositories.
    """)


def main():
    # Ensure at least a command is provided
    if len(sys.argv) < 2:
        show_usage()
        sys.exit(1)

    # Initialize the Git repository manager
    manager = GitRepoManager()

    # Check the provided arguments and call the corresponding method from GitRepoManager
    command = sys.argv[1]

    start_time = time.time()  # Capture the start time before the operation

    operation_description = ""  # Variable to hold the operation description

    if command in ['-s', '--status']:
        operation_description = "Status check"
        print(f"\nGitGulf: {operation_description}")
        manager.status()
    elif command in ['-f', '--fetch']:
        operation_description = "Fetch operation"
        print(f"\nGitGulf: {operation_description}")
        manager.fetch()
    elif command in ['-p', '--pull']:
        operation_description = "Pull operation"
        print(f"\nGitGulf: {operation_description}")
        manager.pull()
    elif command in ['-pr', '--prune']:
        operation_description = "prune operation"
        print(f"\nGitGulf: {operation_description}")
        manager.prune()
    elif command in ['-c', '--cleanup']:
        operation_description = "Cleanup operation"
        print(f"\nGitGulf: {operation_description}")
        manager.cleanup()
    elif command in ['-b', '--branch']:
        # Ensure branch name is provided
        if len(sys.argv) < 3:
            print("Error: BRANCH is required for -b/--branch")
            sys.exit(1)
        branch = sys.argv[2]
        operation_description = f"Switching to branch {branch}"
        print(f"\nGitGulf: {operation_description}")
        manager.switch_branch(branch=branch)
    elif command in ['-m', '--main']:
        operation_description = "Switching to main branch"
        print(f"\nGitGulf: {operation_description}")
        manager.switch_branch(branch='development')
    elif command in ['-d', '--development']:
        operation_description = "Switching to development branch"
        print(f"\nGitGulf: {operation_description}")
        manager.switch_branch(branch='development')
    else:
        show_usage()
        sys.exit(1)

    # Calculate the elapsed time after the operation
    elapsed_time = time.time() - start_time
    # Display the elapsed time
    print(
        f"{operation_description} took {elapsed_time:.2f} seconds to complete.")


def main_s():
    sys.argv.append('-s')
    main()


def main_f():
    sys.argv.append('-f')
    main()


def main_p():
    sys.argv.append('-p')
    main()


def main_pr():
    sys.argv.append('-pr')
    main()


def main_c():
    sys.argv.append('-c')
    main()


def main_b():
    sys.argv.insert(1, '-b')
    main()


def main_m():
    sys.argv.append('-m')
    sys.argv.append('main')
    main()


def main_d():
    sys.argv.append('-b')
    sys.argv.append('development')
    main()


if __name__ == "__main__":
    main()
