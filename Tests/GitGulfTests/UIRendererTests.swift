import XCTest
@testable import GitGulfLib

class UIRendererTests: XCTestCase {
	func testBasicLayout() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")
		repo.branch = "main"
		repo.ahead = "0"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true

		let renderer = UIRenderer()
		let frame = renderer.render(repositories: [repo], useANSIColors: false)
		XCTAssertTrue(frame.contains("TestRepo"))
		XCTAssertTrue(frame.contains("main"))
		XCTAssertTrue(frame.contains("Repository Name"))
		XCTAssertTrue(frame.contains("Branch"))
	}

	func testColorStateLoadingRendersWithIncompleteState() {
		let repo = Repository(name: "LoadingRepo", path: "/test/loading")
		repo.branch = "develop"
		repo.colorState = false

		let renderer = UIRenderer()
		let frame = renderer.render(repositories: [repo], useANSIColors: true)
		XCTAssertTrue(frame.contains("LoadingRepo"))
		XCTAssertTrue(frame.contains("develop"))
	}

	func testMultipleRepositories() {
		let repos = [
			Repository(name: "Repo1", path: "/test/repo1"),
			Repository(name: "Repo2", path: "/test/repo2"),
			Repository(name: "Repo3", path: "/test/repo3"),
		]
		for repo in repos {
			repo.branch = "main"
			repo.colorState = true
		}

		let renderer = UIRenderer()
		let frame = renderer.render(repositories: repos, useANSIColors: false)
		XCTAssertTrue(frame.contains("Repo1"))
		XCTAssertTrue(frame.contains("Repo2"))
		XCTAssertTrue(frame.contains("Repo3"))
	}

	func testAheadBehindColumns() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")
		repo.branch = "main"
		repo.ahead = "5"
		repo.behind = "3"
		repo.changes = "2"
		repo.colorState = true

		let renderer = UIRenderer()
		let frame = renderer.render(repositories: [repo], useANSIColors: false)
		// Verify presence of values in the rendered table
		XCTAssertTrue(frame.contains("TestRepo"))
		XCTAssertTrue(frame.contains("main"))
		XCTAssertTrue(frame.contains("5"), "Ahead value should be rendered")
		XCTAssertTrue(frame.contains("3"), "Behind value should be rendered")
		XCTAssertTrue(frame.contains("2"), "Changes value should be rendered")
	}

	func testEmptyRepositoryList() {
		let renderer = UIRenderer()
		let frame = renderer.render(repositories: [], useANSIColors: false)
		// Header present
		XCTAssertTrue(frame.contains("Repository Name"))
		// Split lines: expect header + divider only
		let lines = frame.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
		XCTAssertGreaterThanOrEqual(lines.count, 2, "Should render header and divider for empty list")
		// No data rows after divider
		if lines.count > 2 {
			let dataRows = lines.dropFirst(2).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
			XCTAssertTrue(dataRows.isEmpty, "No repository rows should be rendered")
		}
	}

	func testANSIColorsDisabled() {
		let repo = Repository(name: "NoColor", path: "/test/nocolors")
		repo.branch = "main"
		repo.colorState = true

		let renderer = UIRenderer()
		let frame = renderer.render(repositories: [repo], useANSIColors: false)
		XCTAssertFalse(frame.contains("\u{001B}["))
	}
}
