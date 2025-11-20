import XCTest
@testable import GitGulfLib

class RepositoryManagerTests: XCTestCase {
	func testRepositoryManagerInitialization() async {
		await MainActor.run {
			let manager = RepositoryManager()
			XCTAssertNotNil(manager)
		}
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

	func testRepositoryManagerCanLoadRepositories() async throws {
		let fm = FileManager.default
		let tempRoot = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
		try fm.createDirectory(atPath: tempRoot, withIntermediateDirectories: true)

		// Visible repo
		let visible = (tempRoot as NSString).appendingPathComponent("VisibleRepo")
		try fm.createDirectory(atPath: visible, withIntermediateDirectories: true)
		_ = try await Shell.execute(["git", "-C", visible, "init"])
		try "init\n".write(toFile: (visible as NSString).appendingPathComponent("README.md"), atomically: true, encoding: .utf8)
		_ = try await Shell.execute(["git", "-C", visible, "add", "."])
		_ = try await Shell.execute(["git", "-C", visible, "commit", "-m", "init"])

		// Hidden repo (should be skipped)
		let hidden = (tempRoot as NSString).appendingPathComponent(".HiddenRepo")
		try fm.createDirectory(atPath: hidden, withIntermediateDirectories: true)
		_ = try await Shell.execute(["git", "-C", hidden, "init"])

		// Symlink to visible (should be skipped)
		let linkPath = (tempRoot as NSString).appendingPathComponent("LinkToVisible")
		try? fm.removeItem(atPath: linkPath)
		try fm.createSymbolicLink(atPath: linkPath, withDestinationPath: visible)

		let manager = await MainActor.run { RepositoryManager() }
		await manager.loadRepositories(currentDirectory: tempRoot)

		let names = await MainActor.run { Set(manager.repositories.map { $0.name }) }
		XCTAssertTrue(names.contains("VisibleRepo"))
		XCTAssertFalse(names.contains(".HiddenRepo"))
		XCTAssertFalse(names.contains("LinkToVisible"))
	}

	func testRepositoryManagerSkipsHiddenDirectories() async throws {
		let fm = FileManager.default
		let tempRoot = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
		try fm.createDirectory(atPath: tempRoot, withIntermediateDirectories: true)
		let hidden = (tempRoot as NSString).appendingPathComponent(".HiddenRepo")
		try fm.createDirectory(atPath: hidden, withIntermediateDirectories: true)
		_ = try await Shell.execute(["git", "-C", hidden, "init"])

		let manager = await MainActor.run { RepositoryManager() }
		await manager.loadRepositories(currentDirectory: tempRoot)
		let names = await MainActor.run { Set(manager.repositories.map { $0.name }) }
		XCTAssertFalse(names.contains(".HiddenRepo"))
	}

	func testRepositoryManagerSkipsSymlinks() async throws {
		let fm = FileManager.default
		let tempRoot = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
		try fm.createDirectory(atPath: tempRoot, withIntermediateDirectories: true)

		let target = (tempRoot as NSString).appendingPathComponent("RealRepo")
		try fm.createDirectory(atPath: target, withIntermediateDirectories: true)
		_ = try await Shell.execute(["git", "-C", target, "init"])

		let linkPath = (tempRoot as NSString).appendingPathComponent("SymlinkRepo")
		try? fm.removeItem(atPath: linkPath)
		try fm.createSymbolicLink(atPath: linkPath, withDestinationPath: target)

		let manager = await MainActor.run { RepositoryManager() }
		await manager.loadRepositories(currentDirectory: tempRoot)
		let names = await MainActor.run { Set(manager.repositories.map { $0.name }) }
		XCTAssertFalse(names.contains("SymlinkRepo"))
	}

	func testRepositoryManagerEmptyDirectory() async throws {
		let fm = FileManager.default
		let tempRoot = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
		try fm.createDirectory(atPath: tempRoot, withIntermediateDirectories: true)

		let manager = await MainActor.run { RepositoryManager() }
		await manager.loadRepositories(currentDirectory: tempRoot)
		let count = await MainActor.run { manager.repositories.count }
		XCTAssertEqual(count, 0)
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
