import sys
import time
from gitgulf.repository_manager import GitRepoManager


def show_usage():
    """
    Prints the usage information.
    """
    print("""
    Usage:
        `gitgulf COMMAND`

        or one of the shortcuts:
            `gg COMMAND`, `ggs`, `ggf`, `ggp`, `ggpr`, `ggc`, `ggb BRANCH`, `ggd`

    Commands:
        -s, --status       : Show all the repository statuses.
        -f, --fetch        : Fetch all repositories.
        -p, --pull         : Pull all repositories.
        -pr, --prune       : Prunes objects that are no longer reachable.
        -c, --cleanup      : Clean up and optimize the local repositories.
        -b, --branch BRANCH: Switch all repositories to a specified branch.
        -d, --development  : Switch all repositories to the development branch.

    Shortcuts:
        gg        : Same as gitgulf.
        ggs       : Show all the repository statuses.
        ggf       : Fetch all repositories.
        ggp       : Pull all repositories.
        ggpr      : Prunes objects that are no longer reachable.
        ggc       : Clean up and optimize the local repositories.
        ggb BRANCH: Switch all repositories to a specified branch.
        ggd       : Switch all repositories to the development branch.
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
        operation_description = "status check"
        print(f"\nGitGulf {operation_description}")
        manager.status()
    elif command in ['-f', '--fetch']:
        operation_description = "fetch operation"
        print(f"\nGitGulf {operation_description}")
        manager.fetch()
    elif command in ['-p', '--pull']:
        operation_description = "pull operation"
        print(f"\nGitGulf {operation_description}")
        manager.pull()
    elif command in ['-pr', '--prune']:
        operation_description = "prune operation"
        print(f"\nGitGulf {operation_description}")
        manager.prune()
    elif command in ['-c', '--cleanup']:
        operation_description = "cleanup operation"
        print(f"\nGitGulf {operation_description}")
        manager.cleanup()
    elif command in ['-b', '--branch']:
        # Ensure branch name is provided
        if len(sys.argv) < 3:
            print("Error: BRANCH is required for -b/--branch")
            sys.exit(1)
        branch = sys.argv[2]
        operation_description = f"switching to branch {branch}"
        print(f"\nGitGulf {operation_description}")
        manager.switch_branch(branch=branch)
    elif command in ['-d', '--development']:
        operation_description = "switching to development branch"
        print(f"\nGitGulf {operation_description}")
        manager.switch_branch(branch='development')
    else:
        show_usage()
        sys.exit(1)

    # Calculate the elapsed time after the operation
    elapsed_time = time.time() - start_time
    # Display the elapsed time
    print(
        f"{operation_description.capitalize()} took {elapsed_time:.2f} seconds to complete.")


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


def main_d():
    sys.argv.append('-b')
    sys.argv.append('development')
    main()


if __name__ == "__main__":
    main()
