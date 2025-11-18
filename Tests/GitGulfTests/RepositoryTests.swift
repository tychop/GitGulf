import XCTest
@testable import GitGulfLib

class RepositoryTests: XCTestCase {
	func testRepositoryInitialization() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")
		XCTAssertEqual(repo.name, "TestRepo")
		XCTAssertEqual(repo.path, "/test/repo")
	}

	func testRepositoryHashable() {
		let repo1 = Repository(name: "Repo1", path: "/test/repo1")
		let repo2 = Repository(name: "Repo1", path: "/different/path")
		let repo3 = Repository(name: "Repo2", path: "/test/repo1")

		XCTAssertEqual(repo1.hashValue, repo2.hashValue)
		XCTAssertNotEqual(repo1.hashValue, repo3.hashValue)
	}

	func testRepositoryEquatable() {
		let repo1 = Repository(name: "Repo1", path: "/test/repo1")
		let repo2 = Repository(name: "Repo1", path: "/different/path")
		let repo3 = Repository(name: "Repo2", path: "/test/repo1")

		XCTAssertEqual(repo1, repo2)
		XCTAssertNotEqual(repo1, repo3)
	}

	func testRepositorySetDeduplication() {
		let repo1 = Repository(name: "Repo1", path: "/test/repo1")
		let repo2 = Repository(name: "Repo1", path: "/different/path")

		var set = Set<Repository>()
		set.insert(repo1)
		set.insert(repo2)

		XCTAssertEqual(set.count, 1)
	}

	func testRepositoryStateUpdates() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")

		repo.branch = "main"
		XCTAssertEqual(repo.branch, "main")

		repo.ahead = "5"
		XCTAssertEqual(repo.ahead, "5")

		repo.behind = "3"
		XCTAssertEqual(repo.behind, "3")

		repo.changes = "2"
		XCTAssertEqual(repo.changes, "2")

		repo.colorState = true
		XCTAssertEqual(repo.colorState, true)
	}

	func testRepositorySendableConformance() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")
		let _: @Sendable () -> Void = {
			_ = repo.name
			_ = repo.path
		}
	}

	func testRepositoryDefaultState() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")

		XCTAssertEqual(repo.branch, "")
		XCTAssertEqual(repo.ahead, "0")
		XCTAssertEqual(repo.behind, "0")
		XCTAssertEqual(repo.changes, "0")
		XCTAssertEqual(repo.colorState, false)
	}
}
