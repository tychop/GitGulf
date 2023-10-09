import unittest
from table import Table, Cell, TableRenderer


class TestCell(unittest.TestCase):

    def test_init(self):
        cell = Cell("Hello, world!")

        self.assertEqual(cell.content, "Hello, world!")
        self.assertEqual(cell.justify, "left")
        self.assertEqual(cell.color, ANSI_WHITE)

        cell = Cell("Hello, world!", justify="right", color=ANSI_RED)

        self.assertEqual(cell.content, "Hello, world!")
        self.assertEqual(cell.justify, "right")
        self.assertEqual(cell.color, ANSI_RED)


class TestTable(unittest.TestCase):

    def test_init(self):
        table = Table()
        self.assertEqual(table.rows, [])


class TestTableIntegration(unittest.TestCase):

    def test_render_table(self):
        table = Table()
        table.add_row(["Name", "Age"])
        table.add_row(["John Doe", 30])

        renderer = TableRenderer(table, ANSI_GREY, ANSI_WHITE)
        rendered_table = renderer.render()

        expected_rendered_table = """
    ╔═══════╦═══════╗
    ║ Name  ║ Age  ║
    ╠═══════╬═══════╣
    ║ John Doe ║ 30 ║
    ╚═══════╩═══════╝
"""

        self.assertEqual(rendered_table, expected_rendered_table)

if __name__ == '__main__':
    unittest.main()
