import os
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor, wait


class GitRepo:

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Initialization
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def __init__(self, base_directory, relative_path):
        self.path = os.path.join(base_directory, relative_path)
        self.name = relative_path

        # Variables
        self.branch = ""
        self.ahead = 0
        self.behind = 0
<<<<<<< HEAD
        self.changes = 0
=======
        self.modifications = 0
>>>>>>> acf26013a8962572b1b1900339c9908ea7134174
        self.completed = False

        # Populate the string variables
        self._update()

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Public functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def fetch(self):
        self._run_git_command('fetch')
        self._update()

    def pull(self):
        self._run_git_command('pull')
        self._update()

    def switch_branch(self, branch: str):
        self._run_git_command('checkout', branch)
        self._update()

    def prune(self):
        self._run_git_command('prune')
        self._update()

    def cleanup(self):
        self._run_git_command('gc')
        self._update()

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Private functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def _update(self):
        with ThreadPoolExecutor(max_workers=2) as executor:
            futures = [
                executor.submit(self._get_branch_name),
                executor.submit(self._get_branch_details)
            ]

            # This will block until all futures are done
            done, not_done = wait(futures)

            for future in done:
                try:
                    future.result()  # This will re-raise any exception that occurred during execution
                except Exception as e:
                    # handle exception
                    print(f"An error occurred: {str(e)}")

        self.completed = True

    def _run_git_command(self, *args):
        result = subprocess.run(
            ['git', *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=self.path
        )

        return result.stdout.decode('utf-8').strip()

    def _get_branch_name(self):
        try:
            # Run git status -b and get the first line which contains branch info.
            status_output = self._run_git_command(
                'status', '-b').split('\n')[0]

            # Regular expression pattern to extract the branch name.
            pattern = r"On branch (\S+)"
            match = re.search(pattern, status_output)

            # If a match is found, update self.branch, else assign 'HEAD'.
            self.branch = match.group(1) if match else 'HEAD'
        except Exception as e:
            print(f"Error retrieving branch name: {str(e)}")
            # In case of an error, set branch as 'HEAD' or handle accordingly.
            self.branch = 'HEAD'

    def _get_branch_details(self):
        try:
            status_output = self._run_git_command('status', '-sb')

            # Extract the number of commits ahead.
            try:
                self.ahead = int(re.search(
                    r'ahead (\d+)', status_output).group(1)) if 'ahead' in status_output else 0
            except AttributeError:
                self.ahead = 0
                # Optionally: log the error if a logging system is utilized.

            # Extract the number of commits behind.
            try:
                self.behind = int(re.search(
                    r'behind (\d+)', status_output).group(1)) if 'behind' in status_output else 0
            except AttributeError:
                self.behind = 0
                # Optionally: log the error if a logging system is utilized.

            # Extract the number of modifications.
            try:
                self.modifications = len(status_output.splitlines()) - 1
            except Exception:
                self.modifications = 0
                # Optionally: log the error if a logging system is utilized.

        except Exception:
            # General error handling for any other unexpected issue.
<<<<<<< HEAD
            self.ahead, self.behind, self.changes = 0, 0, 0
=======
            self.ahead, self.behind, self.modifications = 0, 0, 0
>>>>>>> acf26013a8962572b1b1900339c9908ea7134174
            # Optionally: log the error if a logging system is utilized.
