import sys
from gitripple.repository_manager import GitRepoManager


def show_usage():
    """
    Prints the usage information for this script.
    """
    print("""
    Usage:
        `gitripple COMMAND`

        or one of the shortcuts:
            `gr COMMAND`, `grs`, `grf`, `grp`, `grpr`, `grc`, `grb BRANCH`, `grd`

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
    if command in ['-s', '--status']:
        manager.status()
    elif command in ['-f', '--fetch']:
        manager.fetch()
    elif command in ['-p', '--pull']:
        manager.pull()
    elif command in ['-pr', '--prune']:
        manager.prune()
    elif command in ['-c', '--cleanup']:
        manager.cleanup()
    elif command in ['-b', '--branch']:
        # Ensure branch name is provided
        if len(sys.argv) < 3:
            print("Error: BRANCH is required for -b/--branch")
            sys.exit(1)
        branch = sys.argv[2]
        manager.switch_branch(branch=branch)
    elif command in ['-d', '--development']:
        manager.switch_branch(branch='development')
    else:
        show_usage()
        sys.exit(1)


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
