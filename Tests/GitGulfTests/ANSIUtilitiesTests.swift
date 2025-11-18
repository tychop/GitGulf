import XCTest
@testable import GitGulfLib

class ANSIUtilitiesTests: XCTestCase {
	func testReplacingFirstOccurrenceBehavior() {
		let original = "abc...def...ghi"
		let result = original.replacingFirstOccurrence(of: "...", with: "-")
		// Replaces first occurrence that's not at start
		XCTAssertEqual(result, "abc-def...ghi")
	}

	func testStripSimple() {
		let colored = "\u{001B}[31mhello\u{001B}[0m"
		let stripped = colored.withoutANSIEscapeCodes
		XCTAssertEqual(stripped, "hello")
	}

	func testStripNested() {
		let s = "\u{001B}[31mred\u{001B}[0m and \u{001B}[32mgreen\u{001B}[0m"
		let stripped = s.withoutANSIEscapeCodes
		XCTAssertEqual(stripped, "red and green")
	}

	func testVisibleWidth() {
		let colored = "\u{001B}[31mabc\u{001B}[0m"
		XCTAssertEqual(colored.characterCountExcludingANSIEscapeCodes, 3)
	}
}
