import re
import shutil

# ANSI Escape Codes for colors
ANSI_RESET = "\033[0m"
ANSI_BOLD_BRIGHT_WHITE = "\033[1;97m"
ANSI_WHITE = "\033[0;97m"
ANSI_RED = "\033[0;31m"
ANSI_GREEN = "\033[0;32m"
ANSI_PURPLE = "\033[0;35m"
ANSI_CYAN = "\033[0;36m"
ANSI_GREY = "\033[0;90m"
ANSI_BRIGHT_YELLOW = "\033[93m"

PADDING_CHAR = "…"  # "─"
SEPARATOR_LINE_CHAR = "═"  # "═" "─"
SEPARATOR_CROSS_CHAR = "╪"  # "┼" "╪" "╬"
SEPARATOR_CULUMN_CHAR = "│"  # "║" "│"


class Cell:

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Initialization
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def __init__(self, content, justify="left", color=ANSI_WHITE):
        """
        Initialize the Cell instance with content, justification, and color.

        Parameters:
            content (str): The text content to be displayed in the cell.
            justify (str, optional): Text justification ("left" or "right"). Default is "left".
            color (str, optional): ANSI color code for text color. Default is ANSI_WHITE.
        """
        self.justify = justify
        self.color = color
        self.content = str(content) if str(content) != "0" else PADDING_CHAR * len(
            str(content))
        self.width = len(self.content)


class Table:

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Initialization
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def __init__(self):
        """
        Initialize the Table instance with an empty header row, rows, and column widths.
        """
        self.header_row = []
        self.rows = []
        self.column_widths = []

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Public functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def add_header_row(self, row):
        """
        Add a header row to the table and set its width as maximum column width.

        Parameters:
            row (list): List of Cell objects representing the header row.
        """
        self.header_row = row
        self.set_max_column_widths(row)

    def add_row(self, row, grey_out):
        """
        Add a row to the table and adjust maximum column widths accordingly.

        Parameters:
            row (list): List of Cell objects representing a data row.
            grey_out (bool): Flag indicating the row should be greyed out.
        """
        if grey_out:
            for cell in row:
                cell.color = ANSI_GREY
        self.rows.append(row)
        self.set_max_column_widths(row)

    def set_max_column_widths(self, row):
        """
        Update maximum column widths based on the provided row.

        Parameters:
            row (list): List of Cell objects used to potentially update column widths.
        """
        if not self.column_widths:
            self.column_widths = [0] * len(row)
        for i, cell in enumerate(row):
            self.column_widths[i] = max(
                self.column_widths[i], len(cell.content))


class TableRenderer:

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Initialization
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def __init__(self, table, separator_color, padding_color):
        """
        Initialize the TableRenderer with a table, separator color, and padding color.

        Parameters:
            table (Table): Instance of Table to be rendered.
            separator_color (str): ANSI color code for the separator lines.
            padding_color (str): ANSI color code for padding characters.
        """
        self.table = table
        self.padding_color = padding_color
        self.separator_color = separator_color

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Public functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    def render(self):
        """
        Render the table as a string, combining headers, rows, and separators.

        Returns:
            str: The rendered table string.
        """
        header_row_str = self._postfix_line(self._generate_row_string(self.table.header_row, " "))
        separator_str = self._postfix_line(self._generate_separator_string())
        data_rows_str = '\n'.join(self._postfix_line(self._generate_row_string(row, PADDING_CHAR)) for row in self.table.rows)
        return f"{header_row_str}\n{separator_str}\n{data_rows_str}"

    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # Private functions
    # ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

    @staticmethod
    def _remove_ansi_codes(input_string):
        """
        Remove ANSI escape codes from a string.

        Parameters:
            input_string (str): Input string potentially containing ANSI codes.

        Returns:
            str: The string without ANSI codes.
        """
        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]')
        return ansi_escape.sub('', input_string)

    def _get_terminal_width(self):
        """
        Retrieve the current terminal's width in columns.

        This method utilizes the `shutil.get_terminal_size()` function to determine
        the width of the terminal. It should be platform-independent and work on both
        Unix-like systems and Windows.

        Returns:
            int: The width of the terminal in columns.

        Raises:
            OSError: If the terminal size cannot be determined.
        """
        return shutil.get_terminal_size().columns

    def _postfix_line(self, string):
        """
        Appends spaces to the end of the given string until it reaches the width
        of the terminal.

        This method determines the number of spaces required to make the string
        length equal to the terminal width, taking into account any ANSI color
        codes that may be present in the string. The result is a string that,
        when printed, will occupy the entire width of the terminal.

        Args:
            string (str): The input string to which spaces will be appended.

        Returns:
            str: The input string postfixed with the required number of spaces
                 to make its printed length equal to the terminal width.

        Note:
            This method relies on the `_get_terminal_width` method to determine
            the width of the terminal and the `_remove_ansi_codes` method to
            calculate the printed length of the string without ANSI codes.
        """
        terminal_width = self._get_terminal_width()
        space_taken = len(self._remove_ansi_codes(string))
        space_left = terminal_width - space_taken
        postfix = " " * space_left

        return string + postfix

    def _colored_string(self, string, color):
        """
        Wrap a string with ANSI escape codes to apply color.

        Parameters:
            string (str): The string to be colored.
            color (str): The ANSI escape code for the desired color.

        Returns:
            str: The colored string.
        """
        return color + string + ANSI_RESET

    def _padding_string(self, padding, width, string_length):
        """
        Generate a string for padding, considering available space and applying color.

        Parameters:
            padding (str): The character to be used for padding.
            width (int): The total available width for padding.
            string_length (int): The length of the original, non-padded string.

        Returns:
            str: The colored padding string.
        """
        padding_width = width - string_length
        return self.padding_color + padding[
            :padding_width] + ANSI_RESET if padding_width > 0 else ""

    def _align_left(self, content, padding, width):
        """
        Align the content to the left, applying padding on the right.

        Parameters:
            content (str): The content to be aligned.
            padding (str): The padding character.
            width (int): The width of the area within which content is aligned.

        Returns:
            str: The left-aligned string.
        """
        content_padding = self._padding_string(
            padding, width, len(self._remove_ansi_codes(content)))
        result = (content + content_padding).replace(PADDING_CHAR, " ", 1)
        return result

    def _align_right(self, content, padding, width):
        """
        Align the content to the right, applying padding on the left.

        Parameters:
            content (str): The content to be aligned.
            padding (str): The padding character.
            width (int): The width of the area within which content is aligned.

        Returns:
            str: The right-aligned string.
        """
        padding = self._padding_string(
            padding, width, len(self._remove_ansi_codes(content)))
        result = padding + content
        if self._remove_ansi_codes(content).isdigit():
            result = result[::-1].replace(PADDING_CHAR, " ", 1)[::-1]
        return result

    def _format_cell_content(self, string, padding_char, width, justify, color):
        """
        Format cell content considering justification, width, and color.

        Parameters:
            string (str): The content to be formatted.
            padding_char (str): The padding character.
            width (int): The width of the cell.
            justify (str): Text justification ("left" or "right").
            color (str): ANSI color code for text color.

        Returns:
            str: The formatted string.
        """
        if string == PADDING_CHAR:
            return self.padding_color + \
                (padding_char * width) + ANSI_RESET
        content = self._colored_string(string, color)
        padding = padding_char * width
        if justify == "left":
            return self._align_left(content, padding, width)
        else:
            return self._align_right(content, padding, width)

    def _generate_row_string(self, row, padding_char):
        """
        Generate a string for a row, padding and combining its cell contents.

        Parameters:
            row (list): A list of Cell objects representing the row.
            padding_char (str): The padding character.

        Returns:
            str: The generated row string.
        """
        padded_cells = [
            self._format_cell_content(cell.content, padding_char,
                                      self.table.column_widths[i], cell.justify,
                                      cell.color) for i, cell in enumerate(row)
        ]
        return (self.separator_color + " " + SEPARATOR_CULUMN_CHAR + " " + ANSI_RESET).join(padded_cells)

    def _generate_separator_string(self):
        """
        Generate a separator string for visually dividing rows in the table.

        Returns:
            str: The generated separator string.
        """
        sep_parts = [SEPARATOR_LINE_CHAR * (width + 2)
                     for width in self.table.column_widths]
        return self.separator_color + SEPARATOR_CROSS_CHAR.join(sep_parts)[1:-1] + ANSI_RESET
