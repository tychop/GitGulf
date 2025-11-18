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

	func testColorStateLoading() {
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
		XCTAssertTrue(frame.contains("TestRepo"))
	}

	func testEmptyRepositoryList() {
		let renderer = UIRenderer()
		let frame = renderer.render(repositories: [], useANSIColors: false)
		XCTAssertTrue(frame.contains("Repository Name"))
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
