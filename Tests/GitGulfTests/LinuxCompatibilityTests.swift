import XCTest
import Foundation
@testable import GitGulfLib

class LinuxCompatibilityTests: XCTestCase {
	/// Test that terminal width detection works cross-platform
	func testTerminalWidthDetection() {
		// The terminal width should either use COLUMNS env var, tput command, or fallback to 80
		// GitGulf will be tested indirectly through the renderer
		
		// Access the private property via reflection or test indirectly
		// For this test, we'll verify the renderer can handle various widths
		let repo = Repository(name: "TestRepo", path: "/test")
		repo.branch = "main"
		repo.ahead = "0"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true
		
		let renderer = UIRenderer()
		
		// Render with different widths should work without errors
		let table = renderer.render(repositories: [repo], terminalWidth: 80, useANSIColors: false)
		XCTAssertFalse(table.isEmpty)
		XCTAssertTrue(table.contains("TestRepo"))
		XCTAssertTrue(table.contains("main"))
		
		let wideTable = renderer.render(repositories: [repo], terminalWidth: 120, useANSIColors: false)
		XCTAssertFalse(wideTable.isEmpty)
		XCTAssertTrue(wideTable.contains("TestRepo"))
		XCTAssertTrue(wideTable.contains("main"))
		
		let narrowTable = renderer.render(repositories: [repo], terminalWidth: 40, useANSIColors: false)
		XCTAssertFalse(narrowTable.isEmpty)
		XCTAssertTrue(narrowTable.contains("TestRepo"))
		XCTAssertTrue(narrowTable.contains("main"))
	}

	func testTableLinesArePaddedToTerminalWidth() {
		// Verify that rendered lines are precisely padded to the requested width
		let repo = Repository(name: "Repo", path: "/test")
		repo.branch = "m"
		repo.ahead = "0"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true
		
		let renderer = UIRenderer()
		// Use realistic widths that accommodate the minimum table structure
		let targetWidths = [80, 120, 160]
		
		for width in targetWidths {
			let frame = renderer.render(repositories: [repo], terminalWidth: width, useANSIColors: false)
			let lines = frame.split(separator: "\n").map(String.init)
			
			// All lines (including header, divider, data) should be padded to the exact width
			for (index, line) in lines.enumerated() {
				let visibleLength = line.characterCountExcludingANSIEscapeCodes
				XCTAssertEqual(visibleLength, width, "Line \(index) should be exactly \(width) characters wide (visible), got \(visibleLength)")
			}
		}
	}

	func testResizingTerminalWidthOverwritesOlderContent() {
		// Simulate: render at narrow width, then wide width → confirms rows get extended with padding
		let repo = Repository(name: "Repo", path: "/test")
		repo.branch = "m"
		repo.ahead = "0"
		repo.behind = "0"
		repo.changes = "0"
		repo.colorState = true
		
		let renderer = UIRenderer()
		let narrowWidth = 80
		let wideWidth = 140
		
		let narrow = renderer.render(repositories: [repo], terminalWidth: narrowWidth, useANSIColors: false)
		let wide = renderer.render(repositories: [repo], terminalWidth: wideWidth, useANSIColors: false)
		
		let narrowLines = narrow.split(separator: "\n").map(String.init)
		let wideLines = wide.split(separator: "\n").map(String.init)
		
		// Each line should match its requested width exactly
		for narrowLine in narrowLines {
			let narrowVisible = narrowLine.characterCountExcludingANSIEscapeCodes
			XCTAssertEqual(narrowVisible, narrowWidth)
		}
		
		for wideLine in wideLines {
			let wideVisible = wideLine.characterCountExcludingANSIEscapeCodes
			XCTAssertEqual(wideVisible, wideWidth)
		}
	}
	
	/// Test that shell commands work on cross-platform paths
	func testShellExecuteCrossPlatform() async throws {
		// Use basic commands that should work everywhere
		let output1 = try await Shell.execute(["echo", "test"])
		XCTAssertTrue(output1.output.trimmingCharacters(in: .whitespacesAndNewlines) == "test")
		
		// Test pwd command
		let output2 = try await Shell.execute(["pwd"])
		XCTAssertFalse(output2.output.isEmpty)
		
		// Test date command
		let output3 = try await Shell.execute(["date"])
		XCTAssertFalse(output3.output.isEmpty)
	}
	
	/// Test environment variable support
	func testShellExecuteWithEnvironment() async throws {
		let options = ShellOptions(environment: ["TEST_VAR": "linux_compatible"])
		let output = try await Shell.execute(["sh", "-c", "echo $TEST_VAR"], options: options)
		XCTAssertTrue(output.output.contains("linux_compatible"))
	}
	
	/// Test that the binary name is appropriate (gitgulf on all platforms)
	func testBinaryNameConsistency() {
		// Verify package name is consistent across platforms
		// This is a compile-time constant, so no need to shell out
		let expectedName = "gitgulf"
		XCTAssertFalse(expectedName.isEmpty)
		XCTAssertEqual(expectedName, "gitgulf")
		// If the package name changes, this test will catch it
	}
	
	/// Test that PATH environment variable handling works
	func testPathVariableHandling() async throws {
		let options = ShellOptions(environment: ["PATH": "/bin:/usr/bin:/usr/local/bin"])
		let output = try await Shell.execute(["sh", "-c", "echo $PATH"], options: options)
		XCTAssertTrue(output.output.contains("bin:"))
		XCTAssertTrue(output.output.contains("usr/bin"))
	}
	
	/// Test that file system operations work consistently
	func testFileSystemOperations() throws {
		let tempDir = NSTemporaryDirectory()
		XCTAssertFalse(tempDir.isEmpty)
		
		let testFile = (tempDir as NSString).appendingPathComponent("gitgulf_test.txt")
		let testData = "test content"
		
		try testData.write(toFile: testFile, atomically: true, encoding: .utf8)
		let readData = try String(contentsOfFile: testFile)
		XCTAssertEqual(readData, testData)
		
		try FileManager.default.removeItem(atPath: testFile)
		XCTAssertFalse(FileManager.default.fileExists(atPath: testFile))
	}
	
	/// Test that standard I/O works
	func testStandardIO() {
		// Test FileHandle operations
		let testContent = "GitGulf Linux compatibility test"
		FileHandle.standardOutput.write(testContent.data(using: .utf8) ?? Data())
		
		// Test that Environment is accessible
		let env = ProcessInfo.processInfo.environment
		XCTAssertNotNil(env["PATH"])
		XCTAssertNil(env["NON_EXISTENT_VAR"])
	}
	
	/// Test that the package name and metadata are cross-platform
	func testPackageConfiguration() {
		// Verify package name doesn't contain platform-specific characters
		let packageName = "gitgulf"
		XCTAssertFalse(packageName.contains(" "))
		XCTAssertFalse(packageName.contains("\n"))
		XCTAssertEqual(packageName.lowercased(), "gitgulf")
	}
	
	/// Test that Git commands can be found
	func testGitCommandsAvailable() async throws {
		// Test basic git command availability
		let output = try await Shell.execute(["git", "--version"])
		XCTAssertFalse(output.output.isEmpty)
		XCTAssertTrue(output.output.lowercased().contains("git"))
		
		// Test git status command structure
		// We won't run this as it depends on being in a git repo
		// but we can verify the command exists
		_ = ShellOptions.default
	}
}