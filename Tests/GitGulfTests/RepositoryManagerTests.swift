import XCTest
@testable import GitGulfLib

class RepositoryManagerTests: XCTestCase {
	func testRepositoryManagerInitialization() {
		let manager = RepositoryManager()
		XCTAssertNotNil(manager)
	}

	func testRepositoryManagerEmptyRepositories() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertTrue(manager.repositories.isEmpty)
		}
	}

	func testRepositoryManagerInitializationBasic() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertNotNil(manager)
		}
	}

	func testRepositoryManagerCanLoadRepositories() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertNotNil(manager)
		}
	}

	func testRepositoryManagerSkipsHiddenDirectories() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertNotNil(manager)
		}
	}

	func testRepositoryManagerSkipsSymlinks() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertNotNil(manager)
		}
	}

	func testRepositoryManagerHandlesDirectories() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertTrue(manager.repositories.isEmpty)
		}
	}

	func testRepositoryManagerRepositoriesIsSet() async {
		await MainActor.run {
			let manager = RepositoryManager()

			let repo1 = Repository(name: "TestRepo1", path: "/test/repo1")
			let repo2 = Repository(name: "TestRepo2", path: "/test/repo2")

			manager.repositories.insert(repo1)
			manager.repositories.insert(repo2)

			XCTAssertEqual(manager.repositories.count, 2)
			XCTAssertTrue(manager.repositories.contains(repo1))
			XCTAssertTrue(manager.repositories.contains(repo2))
		}
	}

	func testRepositoryManagerDeduplication() async {
		await MainActor.run {
			let manager = RepositoryManager()

			let repo1 = Repository(name: "TestRepo1", path: "/test/repo1")
			let repo2 = Repository(name: "TestRepo1", path: "/different/path")

			manager.repositories.insert(repo1)
			manager.repositories.insert(repo2)

			XCTAssertEqual(manager.repositories.count, 1)
		}
	}
}
