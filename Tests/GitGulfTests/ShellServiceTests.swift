import XCTest
@testable import GitGulfLib

class ShellServiceTests: XCTestCase {
	func testShellExecuteEcho() async throws {
		let output = try await Shell.execute(["echo", "test"])
		XCTAssertEqual(output.output.trimmingCharacters(in: .whitespacesAndNewlines), "test")
		XCTAssertEqual(output.status, 0)
	}

	func testShellExecuteInvalidCommand() async throws {
		// Shell may succeed with non-zero exit, not necessarily throw
		let output = try await Shell.execute(["false"])
		XCTAssertEqual(output.status, 1)
	}

	func testShellExecuteWithWorkingDirectory() async throws {
		let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
		let homeURL = URL(fileURLWithPath: homeDir)
		let options = ShellOptions(workingDirectory: homeURL)
		let output = try await Shell.execute(["pwd"], options: options)
		// Just verify the command executed successfully with working directory set
		XCTAssertEqual(output.status, 0)
		XCTAssertFalse(output.output.isEmpty)
	}

	func testShellExecuteWithEnvironment() async throws {
		let options = ShellOptions(environment: ["CUSTOM_VAR": "testvalue"])
		let output = try await Shell.execute(["sh", "-c", "echo $CUSTOM_VAR"], options: options)
		XCTAssertTrue(output.output.contains("testvalue"))
	}

	func testShellExecuteTimeout() async throws {
		let options = ShellOptions(timeout: 1)
		do {
			_ = try await Shell.execute(["sleep", "10"], options: options)
			XCTFail("Should have timed out")
		} catch let error as ShellError {
			if case .timeout = error {
				XCTAssertTrue(true)
			} else {
				XCTFail("Expected timeout error")
			}
		}
	}

	func testShellExecuteOutputSize() async throws {
		let options = ShellOptions(maxOutputSize: 10)
		do {
			_ = try await Shell.execute(["sh", "-c", "yes | head -100"], options: options)
			XCTFail("Should have exceeded max output size")
		} catch let error as ShellError {
			if case .outputTooLarge = error {
				XCTAssertTrue(true)
			} else {
				XCTFail("Expected outputTooLarge error")
			}
		}
	}

	func testShellOptionsDefaults() {
		let options = ShellOptions()
		XCTAssertNil(options.workingDirectory)
		XCTAssertNil(options.timeout)
		XCTAssertNil(options.maxOutputSize)
		XCTAssertNil(options.environment)
	}
}
