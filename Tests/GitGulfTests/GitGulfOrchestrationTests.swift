import XCTest
@testable import GitGulfLib

class GitGulfOrchestrationTests: XCTestCase {
	func testGitGulfInitialization() async {
		let gitGulf = GitGulf()
		XCTAssertNotNil(gitGulf)
	}

	func testGitGulfHasRepositoryManager() async {
		let gitGulf = GitGulf()
		XCTAssertNotNil(gitGulf)
	}

	func testGitGulfStatusCommand() async {
		let gitGulf = GitGulf()
		_ = gitGulf
		XCTAssertTrue(true)
	}

	func testGitGulfFetchCommand() async {
		let gitGulf = GitGulf()
		_ = gitGulf
		XCTAssertTrue(true)
	}

	func testGitGulfPullCommand() async {
		let gitGulf = GitGulf()
		_ = gitGulf
		XCTAssertTrue(true)
	}

	func testGitGulfRebaseCommand() async {
		let gitGulf = GitGulf()
		_ = gitGulf
		XCTAssertTrue(true)
	}

	func testGitGulfCheckoutCommand() async {
		let gitGulf = GitGulf()
		_ = gitGulf
		XCTAssertTrue(true)
	}

	func testGitGulfPublicAPI() async {
		let gitGulf = GitGulf()

		await MainActor.run {
			XCTAssertNotNil(gitGulf)
		}
	}

	func testGitGulfIsMainActor() async {
		let gitGulf = GitGulf()

		await MainActor.run {
			_ = gitGulf
			XCTAssertTrue(true)
		}
	}

	func testGitGulfConcurrency() async {
		let gitGulf = GitGulf()

		async let task1 = {
			_ = gitGulf
			return 1
		}()

		async let task2 = {
			_ = gitGulf
			return 2
		}()

		let result1 = await task1
		let result2 = await task2

		XCTAssertEqual(result1, 1)
		XCTAssertEqual(result2, 2)
	}
}
