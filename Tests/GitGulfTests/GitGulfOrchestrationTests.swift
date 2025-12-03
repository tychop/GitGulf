import XCTest
@testable import GitGulfLib

class GitGulfOrchestrationTests: XCTestCase {
	private func withTempCWD<T>(_ body: () async throws -> T) async throws -> T {
		let fm = FileManager.default
		let temp = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
		try fm.createDirectory(atPath: temp, withIntermediateDirectories: true)
		let original = fm.currentDirectoryPath
		fm.changeCurrentDirectoryPath(temp)
		defer { fm.changeCurrentDirectoryPath(original) }
		return try await body()
	}

	func testGitGulfInitialization() async {
		let gitGulf = GitGulf()
		XCTAssertNotNil(gitGulf)
	}

	func testGitGulfStatusCommandCompletes() async throws {
		try await withTempCWD {
			let g = GitGulf()
			await g.status()
			XCTAssertTrue(true)
		}
	}

	func testGitGulfFetchPullRebaseComplete() async throws {
		try await withTempCWD {
			let g = GitGulf()
			await g.fetch()
			await g.pull()
			await g.rebase()
			XCTAssertTrue(true)
		}
	}

	func testGitGulfCheckoutCompletesOnEmptyDir() async throws {
		try await withTempCWD {
			let g = GitGulf()
			await g.checkout(branch: "main")
			XCTAssertTrue(true)
		}
	}
}
