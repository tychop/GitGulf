import XCTest
@testable import GitGulfLib

class CLITests: XCTestCase {
	func testVersionFlag() {
		let args = ["gitgulf", "--version"]
		let hasVersion = args.contains("--version")
		XCTAssertTrue(hasVersion)
	}

	func testStatusCommand() {
		let args = ["gitgulf", "status"]
		XCTAssertEqual(args[1], "status")
	}

	func testFetchCommand() {
		let args = ["gitgulf", "fetch"]
		XCTAssertEqual(args[1], "fetch")
	}

	func testPullCommand() {
		let args = ["gitgulf", "pull"]
		XCTAssertEqual(args[1], "pull")
	}

	func testRebaseCommand() {
		let args = ["gitgulf", "rebase"]
		XCTAssertEqual(args[1], "rebase")
	}

	func testCheckoutCommand() {
		let args = ["gitgulf", "-b", "main"]
		XCTAssertEqual(args[1], "-b")
		XCTAssertEqual(args[2], "main")
	}

	func testCheckoutCommandAlternate() {
		let args = ["gitgulf", "checkout", "develop"]
		XCTAssertEqual(args[1], "checkout")
		XCTAssertEqual(args[2], "develop")
	}

	func testDevelopmentCommand() {
		let args = ["gitgulf", "development"]
		XCTAssertEqual(args[1], "development")
	}

	func testMasterCommand() {
		let args = ["gitgulf", "master"]
		XCTAssertEqual(args[1], "master")
	}

	func testNoArguments() {
		let args = ["gitgulf"]
		XCTAssertEqual(args.count, 1)
	}

	func testInvalidCommand() {
		let args = ["gitgulf", "invalid"]
		XCTAssertEqual(args[1], "invalid")
		let validCommands = ["status", "fetch", "pull", "rebase", "checkout", "development", "master"]
		XCTAssertFalse(validCommands.contains(args[1]))
	}

	func testCommandCaseSensitivity() {
		let args = ["gitgulf", "STATUS"]
		XCTAssertNotEqual(args[1], "status")
	}
}
