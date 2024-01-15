import os
import sys

from concurrent.futures import ThreadPoolExecutor, as_completed
from gitgulf.repository import GitRepo
from gitgulf.table import (
    Table, TableRenderer, Cell, ANSI_BOLD_BRIGHT_WHITE, ANSI_WHITE,
    ANSI_RED, ANSI_GREEN, ANSI_CYAN, ANSI_PURPLE, ANSI_GREY
)


class GitRepoManager:

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Initialization
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def __init__(self):
        """
        Initializes GitRepoManager instance.

        Scans the current working directory for Git repositories, initializes
        and sorts them.
        """
        base_directory = os.getcwd()
        repo_paths = self._get_repo_paths(base_directory)

        if not repo_paths:
            print(
                "Exiting. Gitgrove can't find any git repositories in the current directory.")
            sys.exit(1)

        self.repos = self._initialize_repos(base_directory, repo_paths)
        self._sort_repos()
        self._reset_completed_flags(with_value=False)

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Public functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def status(self):
        """
        Displays the status of all repositories.

        Resets completion flags, fetches the status, and displays it in tabular
        format.
        """
        self._reset_completed_flags(with_value=True)
        self._show_status()

    def fetch(self):
        """
        Fetches all repositories concurrently.

        Initiates the fetch operation for all repositories and displays
        their statuses in tabular format.
        """
        self._generic_repo_action(
            action_method='fetch',
            action_name='fetching'
        )
        self._show_status()

    def pull(self):
        """
        Pulls all repositories concurrently.

        Initiates the pull operation for all repositories and displays
        their statuses in tabular format.
        """
        self._generic_repo_action(
            action_method='pull',
            action_name='pulling'
        )
        self._show_status()

    def switch_branch(self, branch):
        """
        Switches the branch for all repositories concurrently.

        Args:
            branch (str): The name of the branch to switch to.

        Initiates the branch switch operation for all repositories and
        displays their statuses in tabular format.
        """
        with ThreadPoolExecutor() as executor:
            futures = {
                executor.submit(repo.switch_branch, branch): repo for repo in self.repos
            }

            self._handle_futures(futures=futures)
            self._show_status()

    def prune(self):
        """
        Prunes all repositories concurrently.

        Initiates the prune operation for all repositories and displays
        their statuses in tabular format.
        """
        with ThreadPoolExecutor() as executor:
            futures = {
                executor.submit(repo.prune): repo for repo in self.repos
            }

            self._handle_futures(futures=futures)
            self._show_status()

    def cleanup(self):
        """
        Cleans up all repositories concurrently.

        Initiates the cleanup operation for all repositories and displays
        their statuses in tabular format.
        """
        with ThreadPoolExecutor() as executor:
            futures = {
                executor.submit(repo.cleanup): repo for repo in self.repos
            }

            self._handle_futures(futures=futures)
            self._show_status()

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Private functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    @staticmethod
    def _get_repo_paths(base_directory):
        """
        Retrieves paths of all Git repositories within the base directory.

        Args:
            base_directory (str): The directory to search for Git repositories.

        Returns:
            list[str]: A list of paths for discovered Git repositories.
        """
        return [
            dir_name for dir_name in os.listdir(base_directory)
            if os.path.isdir(os.path.join(base_directory, dir_name))
            and '.git' in os.listdir(os.path.join(base_directory, dir_name))
        ]

    @staticmethod
    def _determine_branch_color(repo):
        """
        Determines color code for branch status display.

        Args:
            repo (GitRepo): A repository instance to determine color for.

        Returns:
            str: ANSI color code for displaying branch status.
        """
        if int(repo.behind) > 0:
            return ANSI_RED
        elif int(repo.ahead) > 0:
            return ANSI_PURPLE
        elif int(repo.modifications) > 0:
            return ANSI_CYAN
        else:
            return ANSI_GREEN

    @staticmethod
    def _create_cell(content, justify="left", color=ANSI_WHITE):
        """
        Creates a Cell instance for tabular rendering.

        Args:
            content (str): The text content of the cell.
            justify (str, optional): Text justification within the cell.
                                     Defaults to "left".
            color (str, optional): ANSI color code for text display.
                                   Defaults to ANSI_WHITE.

        Returns:
            Cell: A table cell instance containing the provided content.
        """
        return Cell(content=str(content), justify=justify, color=color)

    def _initialize_repos(self, base_directory, repo_paths):
        """
        Initializes Git repositories based on given paths.

        Args:
            base_directory (str): The base directory containing Git repositories.
            repo_paths (list[str]): Paths to Git repositories.

        Returns:
            list[GitRepo]: A list of initialized GitRepo instances.
        """
        with ThreadPoolExecutor(max_workers=len(repo_paths)) as executor:
            futures = [
                executor.submit(GitRepo, base_directory, relative_path)
                for relative_path in repo_paths
            ]
            return [future.result() for future in futures]

    def _show_status(self):
        """
        Renders and displays the status table for all repositories.

        Returns:
            int: The number of line breaks in the rendered status table.
        """
        table = Table()
        header_contents = ["Repository Name",
                           "Branch", "Ahead", "Behind", "Modifications"]
        header_cells = [self._create_cell(
            content, color=ANSI_BOLD_BRIGHT_WHITE) for content in header_contents]
        table.add_header_row(header_cells)

        for repo in self.repos:
            branch_color = self._determine_branch_color(repo)
            row_cells = [
                self._create_cell(repo.name, color=ANSI_WHITE),
                self._create_cell(repo.branch, color=branch_color),
                self._create_cell(repo.ahead, justify="right",
                                  color=ANSI_PURPLE),
                self._create_cell(
                    repo.behind, justify="right", color=ANSI_RED),
                self._create_cell(
                    repo.modifications, justify="right", color=ANSI_CYAN),
            ]

            table.add_row(row=row_cells, grey_out=not repo.completed)

        renderer = TableRenderer(
            table=table,
            separator_color=ANSI_WHITE,
            padding_color=ANSI_GREY
        )

        result = f"\n{renderer.render()}\n\n"
        print(result, end="")
        return result.count("\n")

    def _reset_completed_flags(self, with_value):
        """
        Resets the 'completed' attribute for all repository instances.

        Args:
            with_value (bool): The value to set for 'completed' attribute.
        """
        for repo in self.repos:
            repo.completed = with_value

    def _sort_repos(self):
        """
        Sorts repository instances alphabetically based on their name.
        """
        self.repos.sort(key=lambda repo: repo.name)

    def _generic_repo_action(self, action_method: str, action_name: str):
        """
        Executes a generic action method concurrently on all repositories.

        Args:
            action_method (str): The name of the repository method to execute.
            action_name (str): A string describing the action, used in error messages.
        """
        with ThreadPoolExecutor() as executor:
            futures = [
                executor.submit(
                    self._repo_action,
                    repo,
                    action_method,
                    action_name
                ) for repo in self.repos
            ]
            for future in as_completed(futures):
                self._handle_future(future)

    def _repo_action(self, repo, action_method, action_name):
        """
        Executes an action method on a single repository.

        Args:
            repo (GitRepo): The repository instance.
            action_method (str): The name of the repository method to execute.
            action_name (str): A string describing the action, used in error messages.
        """
        try:
            getattr(repo, action_method)()
            repo.completed = True
        except Exception as e:
            repo_path = getattr(repo, 'path', 'Unknown')
            print(f"Error {action_name} {repo_path}: {e}")

    def _handle_futures(self, futures):
        """
        Handles concurrent futures by displaying the status and errors.

        Args:
            futures (dict[concurrent.futures.Future, GitRepo]): A dictionary mapping futures
            to their corresponding repository instances.
        """
        for future in as_completed(futures):
            self._handle_future(future=future)

    def _handle_future(self, future):
        """
        Handles a single future by displaying the status and errors.

        Args:
            future (concurrent.futures.Future): The future to handle.
        """
        # Print table
        num_lines = self._show_status()
        # Make the cursor go op num_lines lines so the next iteration
        # in this for loop can overwrite the table with new data
        print("\x1b[{}A".format(num_lines), end="")

        if future.exception():
            print(f"Error: {future.exception()}")
