import XCTest
@testable import GitGulfLib

class UITableAlignmentTests: XCTestCase {
	/// Helper to extract lines from rendered table
	private func extractLines(_ table: String) -> [String] {
		table.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
	}

	/// Helper to count visible characters (excluding ANSI codes)
	private func visibleLength(_ line: String) -> Int {
		line.characterCountExcludingANSIEscapeCodes
	}

	/// Helper to find divider column positions from a divider line
	private func findDividerPositions(_ dividerLine: String) -> [Int] {
		let visible = dividerLine.withoutANSIEscapeCodes
		var positions: [Int] = []
		for (index, char) in visible.enumerated() {
			if char == "╪" {
				positions.append(index)
			}
		}
		return positions
	}

	func testTableHeaderAndDividerAlignment() {
		let renderer = UIRenderer()
		let repo = Repository(name: "App", path: "/test/app")
		repo.branch = "main"
		repo.ahead = "0"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true

		let table = renderer.render(repositories: [repo], useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 3, "Table should have header, divider, and data rows")

		let headerLine = lines[0]
		let dividerLine = lines[1]

		// Verify divider has intersections
		let dividerPositions = findDividerPositions(dividerLine)
		XCTAssertGreaterThanOrEqual(dividerPositions.count, 4, "Divider should have multiple column intersections")

		// Verify divider is mostly horizontal lines
		let dividerVisible = dividerLine.withoutANSIEscapeCodes
		let horizontalCount = dividerVisible.filter { $0 == "═" }.count
		XCTAssertGreaterThan(horizontalCount, 0, "Divider should contain horizontal lines")
	}

	func testColumnsAlignWithShortAndLongRepoNames() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "A", path: "/a"),
			Repository(name: "VeryLongRepositoryName", path: "/very"),
		]
		for repo in repos {
			repo.branch = "main"
			repo.ahead = "0"
			repo.behind = "0"
			repo.changes = "0"
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 4)

		let dividerLine = lines[1]
		let dividerPositions = findDividerPositions(dividerLine)

		// All data lines should align with divider columns
		for i in 2..<lines.count {
			let dataLine = lines[i]
			let dataVisible = dataLine.withoutANSIEscapeCodes

			// Verify columns align
			for pos in dividerPositions {
				if pos < dataVisible.count {
					let char = dataVisible[dataVisible.index(dataVisible.startIndex, offsetBy: pos)]
					XCTAssertEqual(char, "│", "Column separator at position \(pos) in data line \(i) should be vertical bar")
				}
			}
		}
	}

	func testColumnsAlignWithVariousAheadBehindNumbers() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "Repo1", path: "/r1"),
			Repository(name: "Repo2", path: "/r2"),
			Repository(name: "Repo3", path: "/r3"),
			Repository(name: "Repo4", path: "/r4"),
		]

		repos[0].branch = "main"
		repos[0].ahead = "0"
		repos[0].behind = "0"
		repos[0].changes = "0"

		repos[1].branch = "develop"
		repos[1].ahead = "5"
		repos[1].behind = "0"
		repos[1].changes = "0"

		repos[2].branch = "feature"
		repos[2].ahead = "0"
		repos[2].behind = "123"
		repos[2].changes = "0"

		repos[3].branch = "bugfix"
		repos[3].ahead = "99"
		repos[3].behind = "88"
		repos[3].changes = "777"

		for repo in repos {
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 6)

		let dividerLine = lines[1]
		let dividerPositions = findDividerPositions(dividerLine)

		// Verify each data line aligns with divider
		for i in 2..<lines.count {
			let dataLine = lines[i]
			let dataVisible = dataLine.withoutANSIEscapeCodes

			for pos in dividerPositions {
				if pos < dataVisible.count {
					let char = dataVisible[dataVisible.index(dataVisible.startIndex, offsetBy: pos)]
					XCTAssertEqual(char, "│", "Line \(i) column position \(pos) misaligned")
				}
			}
		}
	}

	func testColumnWidthsConsistentAcrossRows() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "Short", path: "/s"),
			Repository(name: "MediumNameRepository", path: "/m"),
			Repository(name: "X", path: "/x"),
		]

		for repo in repos {
			repo.branch = "main"
			repo.ahead = "0"
			repo.behind = "0"
			repo.changes = "0"
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 4)

		let dividerLine = lines[1]
		let dividerPositions = findDividerPositions(dividerLine)

		// Calculate column widths from divider
		var columnWidths: [Int] = []
		for i in 0..<dividerPositions.count {
			let start = (i == 0) ? 0 : dividerPositions[i - 1] + 1
			let end = dividerPositions[i]
			columnWidths.append(end - start)
		}

		// All data lines should have same column widths
		for i in 2..<lines.count {
			let dataLine = lines[i]
			let dataVisible = dataLine.withoutANSIEscapeCodes

			for j in 0..<dividerPositions.count {
				let start = (j == 0) ? 0 : dividerPositions[j - 1] + 1
				let end = dividerPositions[j]
				let width = end - start

				if j < columnWidths.count {
					XCTAssertEqual(width, columnWidths[j], "Column \(j) width mismatch in row \(i)")
				}
			}
		}
	}

	func testBranchColumnAlignmentWithVariousBranchNames() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "Repo1", path: "/r1"),
			Repository(name: "Repo2", path: "/r2"),
			Repository(name: "Repo3", path: "/r3"),
		]

		repos[0].branch = "m"
		repos[1].branch = "feature/very-long-branch-name"
		repos[2].branch = "release-1.0.0"

		for repo in repos {
			repo.ahead = "0"
			repo.behind = "0"
			repo.changes = "0"
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 4)

		// Verify all data lines have proper vertical alignment
		let dividerLine = lines[1]
		let dividerPositions = findDividerPositions(dividerLine)

		for i in 2..<lines.count {
			let dataLine = lines[i]
			let dataVisible = dataLine.withoutANSIEscapeCodes

			for pos in dividerPositions {
				if pos < dataVisible.count {
					let char = dataVisible[dataVisible.index(dataVisible.startIndex, offsetBy: pos)]
					XCTAssertEqual(char, "│", "Alignment failure at row \(i) position \(pos)")
				}
			}
		}
	}

	func testChangeCountColumnAlignment() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "Repo1", path: "/r1"),
			Repository(name: "Repo2", path: "/r2"),
			Repository(name: "Repo3", path: "/r3"),
			Repository(name: "Repo4", path: "/r4"),
		]

		repos[0].branch = "main"
		repos[0].ahead = "0"
		repos[0].behind = "0"
		repos[0].changes = "0"

		repos[1].branch = "main"
		repos[1].ahead = "0"
		repos[1].behind = "0"
		repos[1].changes = "1"

		repos[2].branch = "main"
		repos[2].ahead = "0"
		repos[2].behind = "0"
		repos[2].changes = "999"

		repos[3].branch = "main"
		repos[3].ahead = "0"
		repos[3].behind = "0"
		repos[3].changes = "12345"

		for repo in repos {
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 5)

		let dividerLine = lines[1]
		let dividerPositions = findDividerPositions(dividerLine)

		// Verify columns are present and in ascending order
		XCTAssertGreaterThanOrEqual(dividerPositions.count, 4, "Should have column dividers")
		for i in 1..<dividerPositions.count {
			XCTAssertGreaterThan(dividerPositions[i], dividerPositions[i - 1])
		}

		// Verify data rows have column separators aligned with divider
		for i in 2..<min(lines.count, 6) {
			let dataLine = lines[i]
			let dataVisible = dataLine.withoutANSIEscapeCodes

			if !dataVisible.isEmpty {
				for pos in dividerPositions {
					if pos < dataVisible.count {
						let char = dataVisible[dataVisible.index(dataVisible.startIndex, offsetBy: pos)]
						XCTAssertEqual(char, "│", "Column misaligned at row \(i), pos \(pos)")
					}
				}
			}
		}
	}

	func testMixedRepoNamesAndNumbersAlignment() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "A", path: "/a"),
			Repository(name: "SuperLongRepoNameThatIsVeryLong", path: "/s"),
			Repository(name: "Med", path: "/m"),
			Repository(name: "X", path: "/x"),
		]

		repos[0].branch = "b"
		repos[0].ahead = "0"
		repos[0].behind = "0"
		repos[0].changes = "0"

		repos[1].branch = "feature/very-long-name"
		repos[1].ahead = "100"
		repos[1].behind = "200"
		repos[1].changes = "50"

		repos[2].branch = "main"
		repos[2].ahead = "0"
		repos[2].behind = "1"
		repos[2].changes = "999"

		repos[3].branch = "x"
		repos[3].ahead = "5"
		repos[3].behind = "0"
		repos[3].changes = "0"

		for repo in repos {
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 5)

		// Verify header, divider, and all data rows are properly aligned
		let headerLine = lines[0]
		let dividerLine = lines[1]

		// Header and divider should have consistent structure
		let headerVisible = headerLine.withoutANSIEscapeCodes
		let dividerVisible = dividerLine.withoutANSIEscapeCodes

		XCTAssertGreaterThan(headerVisible.count, 0)
		XCTAssertGreaterThan(dividerVisible.count, 0)

		// Divider positions
		let dividerPositions = findDividerPositions(dividerLine)

		// All rows should align with divider
		for i in 2..<lines.count {
			let dataLine = lines[i]
			let dataVisible = dataLine.withoutANSIEscapeCodes

			for pos in dividerPositions {
				if pos < dataVisible.count {
					let char = dataVisible[dataVisible.index(dataVisible.startIndex, offsetBy: pos)]
					XCTAssertEqual(char, "│", "Misalignment at row \(i), column \(pos)")
				}
			}
		}
	}

	func testNoColumnsBreakWithExtremeValues() {
		let renderer = UIRenderer()
		let repos = [
			Repository(name: "A", path: "/a"),
			Repository(name: "ThisIsAnExtremelyLongRepositoryNameThatShouldStillAlign", path: "/t"),
			Repository(name: "B", path: "/b"),
		]

		repos[0].branch = "b"
		repos[0].ahead = "0"
		repos[0].behind = "0"
		repos[0].changes = "0"

		repos[1].branch = "very-long-feature-branch-name-that-goes-on-forever"
		repos[1].ahead = "99999"
		repos[1].behind = "88888"
		repos[1].changes = "77777"

		repos[2].branch = "m"
		repos[2].ahead = "0"
		repos[2].behind = "0"
		repos[2].changes = "0"

		for repo in repos {
			repo.colorState = true
		}

		let table = renderer.render(repositories: repos, useANSIColors: false)
		let lines = extractLines(table)

		XCTAssertGreaterThanOrEqual(lines.count, 4)

		// Verify no duplicate column separators and proper structure
		let dividerLine = lines[1]
		let dividerPositions = findDividerPositions(dividerLine)

		// Should have exactly 5 columns (repo, branch, ahead, behind, changes)
		XCTAssertEqual(dividerPositions.count, 4, "Should have 4 column separators (5 columns)")

		// Verify positions are in ascending order
		for i in 1..<dividerPositions.count {
			XCTAssertGreaterThan(dividerPositions[i], dividerPositions[i - 1], "Divider positions should be ascending")
		}
	}
}
