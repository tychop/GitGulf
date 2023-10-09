import unittest
from main import show_usage


class TestMain(unittest.TestCase):

    def test_show_usage(self):
        expected_usage = """
Usage:
    `gitgrove COMMAND`

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
        gg        : Same as gitgrove.
        ggs       : Show all the repository statuses.
        ggf       : Fetch all repositories.
        ggp       : Pull all repositories.
        ggpr      : Prunes objects that are no longer reachable.
        ggc       : Clean up and optimize the local repositories.
        ggb BRANCH: Switch all repositories to a specified branch.
        ggd       : Switch all repositories to the development branch.
"""

        actual_usage = show_usage()

        self.assertEqual(expected_usage, actual_usage)


if __name__ == '__main__':
    unittest.main()
