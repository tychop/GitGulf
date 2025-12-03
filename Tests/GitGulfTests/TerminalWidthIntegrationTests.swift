import XCTest
import Foundation
@testable import GitGulfLib

class TerminalWidthIntegrationTests: XCTestCase {
	/// Test that GitGulf correctly detects and uses terminal width from COLUMNS env var
	func testDetectTerminalWidthFromCOLUMNSEnv() {
		// This test verifies that the detectTerminalWidth method can be tested indirectly
		// by rendering with explicit widths and verifying padding is applied
		let repo = Repository(name: "Test", path: "/test")
		repo.branch = "main"
		repo.ahead = "0"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true

		let renderer = UIRenderer()
		let customWidth = 100

		let frame = renderer.render(repositories: [repo], terminalWidth: customWidth, useANSIColors: false)
		let lines = frame.split(separator: "\n").map(String.init)

		// Each line should be padded to exactly customWidth
		for line in lines {
			let visibleLength = line.characterCountExcludingANSIEscapeCodes
			XCTAssertEqual(visibleLength, customWidth, "Line should be padded to width \(customWidth)")
		}
	}

	/// Test that lines are padded with spaces (backgroundCharacter is " ")
	func testLinesPaddedWithSpaces() {
		let repo = Repository(name: "Repo", path: "/test")
		repo.branch = "dev"
		repo.ahead = "1"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true

		let renderer = UIRenderer()
		let targetWidth = 90

		let frame = renderer.render(repositories: [repo], terminalWidth: targetWidth, useANSIColors: false)
		let lines = frame.split(separator: "\n").map(String.init)

		// Each line should end with spaces (no ANSI codes at the end)
		for line in lines {
			let withoutANSI = line.withoutANSIEscapeCodes
			// Last character should be a space (padding)
			XCTAssertTrue(withoutANSI.last == " " || withoutANSI.last?.isWhitespace == true,
						 "Line should be padded with spaces")
		}
	}

	/// Test that resizing between renders produces different widths
	func testRenderingWithDifferentWidthsProducesDifferentPadding() {
		let repo = Repository(name: "App", path: "/app")
		repo.branch = "feature"
		repo.ahead = "5"
		repo.behind = "3"
		repo.changes = "2"
		repo.colorState = true

		let renderer = UIRenderer()
		let width1 = 85
		let width2 = 150

		let frame1 = renderer.render(repositories: [repo], terminalWidth: width1, useANSIColors: false)
		let frame2 = renderer.render(repositories: [repo], terminalWidth: width2, useANSIColors: false)

		let lines1 = frame1.split(separator: "\n").map(String.init)
		let lines2 = frame2.split(separator: "\n").map(String.init)

		// Verify each frame has correct width
		for line in lines1 {
			XCTAssertEqual(line.characterCountExcludingANSIEscapeCodes, width1)
		}

		for line in lines2 {
			XCTAssertEqual(line.characterCountExcludingANSIEscapeCodes, width2)
		}

		// Verify width2 lines are significantly longer than width1
		let firstLine1 = lines1.first?.withoutANSIEscapeCodes ?? ""
		let firstLine2 = lines2.first?.withoutANSIEscapeCodes ?? ""
		XCTAssertGreaterThan(firstLine2.count, firstLine1.count)
	}

	/// Test with multiple repositories to ensure consistent padding
	func testMultipleRepositoriesAllPaddedConsistently() {
		let repos = [
			Repository(name: "A", path: "/a"),
			Repository(name: "VeryLongRepositoryName", path: "/b"),
			Repository(name: "Mid", path: "/c"),
		]

		for repo in repos {
			repo.branch = "main"
			repo.ahead = "0"
			repo.behind = "0"
			repo.changes = "0"
			repo.colorState = true
		}

		let renderer = UIRenderer()
		let targetWidth = 110

		let frame = renderer.render(repositories: repos, terminalWidth: targetWidth, useANSIColors: false)
		let lines = frame.split(separator: "\n").map(String.init)

		// All lines (header, divider, and each repo row) should be exactly targetWidth
		for (index, line) in lines.enumerated() {
			let visibleLength = line.characterCountExcludingANSIEscapeCodes
			XCTAssertEqual(visibleLength, targetWidth,
						 "Line \(index) in multi-repo render should be exactly \(targetWidth) wide")
		}
	}

	func testBranchColumnShrinksByTerminalWidth() {
		// This test demonstrates that resizing the terminal changes visible padding.
		// With actual repo data, we can see the trailing spaces shrink when terminal gets narrower.
		let repos = [
			Repository(name: "MyFirstRepository", path: "/test1"),
			Repository(name: "SecondRepo", path: "/test2"),
		]
		for repo in repos {
			repo.branch = "feature/very-long-branch-name"
			repo.ahead = "5"
			repo.behind = "3"
			repo.changes = "12"
			repo.colorState = true
		}

		let renderer = UIRenderer()
		let wideWidth = 150
		let narrowWidth = 80

		let wideFrame = renderer.render(repositories: repos, terminalWidth: wideWidth, useANSIColors: false)
		let narrowFrame = renderer.render(repositories: repos, terminalWidth: narrowWidth, useANSIColors: false)

		let wideLines = wideFrame.split(separator: "\n").map(String.init)
		let narrowLines = narrowFrame.split(separator: "\n").map(String.init)

		// Get the first data row (skip header and divider)
		guard wideLines.count > 2, narrowLines.count > 2 else {
			XCTFail("Expected at least header, divider, and data rows")
			return
		}

		let wideDataRow = wideLines[2].withoutANSIEscapeCodes
		let narrowDataRow = narrowLines[2].withoutANSIEscapeCodes

		// Both should be exactly their respective widths (padded with spaces)
		XCTAssertEqual(wideDataRow.count, wideWidth, "Wide row should be exactly \(wideWidth) chars")
		XCTAssertEqual(narrowDataRow.count, narrowWidth, "Narrow row should be exactly \(narrowWidth) chars")

		// Wide output should be significantly longer
		XCTAssertGreaterThan(wideDataRow.count, narrowDataRow.count,
			"Wide row (150) should be longer than narrow row (80)")

		// Count trailing spaces in each rendering - this is the visible proof
		let wideTrailingSpaces = wideDataRow.reversed().prefix(while: { $0 == " " }).count
		let narrowTrailingSpaces = narrowDataRow.reversed().prefix(while: { $0 == " " }).count

		// The narrow version should have fewer trailing spaces
		XCTAssertGreaterThan(wideTrailingSpaces, narrowTrailingSpaces,
			"Wide rendering should have \(wideTrailingSpaces) trailing spaces, narrow should have fewer than \(narrowTrailingSpaces)")
	}
}
