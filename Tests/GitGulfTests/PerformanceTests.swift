import XCTest
@testable import GitGulfLib

class PerformanceTests: XCTestCase {
	func testLargeRepositoryListInitialization() {
		self.measure {
			var repos = [Repository]()
			for i in 0..<1000 {
				repos.append(Repository(name: "Repo\(i)", path: "/test/repo\(i)"))
			}
			XCTAssertEqual(repos.count, 1000)
		}
	}

	func testLargeRepositorySetInsertion() {
		self.measure {
			var set = Set<Repository>()
			for i in 0..<1000 {
				set.insert(Repository(name: "Repo\(i)", path: "/test/repo\(i)"))
			}
			XCTAssertEqual(set.count, 1000)
		}
	}

	func testUIRendererLargeRepositoryList() {
		let repos = (0..<100).map { i in
			let repo = Repository(name: "Repo\(i)", path: "/test/repo\(i)")
			repo.branch = "main"
			repo.ahead = "\(Int.random(in: 0...10))"
			repo.behind = "\(Int.random(in: 0...10))"
			repo.changes = "\(Int.random(in: 0...50))"
			repo.colorState = true
			return repo
		}

		let renderer = UIRenderer()
		self.measure {
			_ = renderer.render(repositories: repos, useANSIColors: false)
		}
	}

	func testRepositoryHashingPerformance() {
		let repos = (0..<1000).map { i in
			Repository(name: "Repo\(i % 100)", path: "/test/repo\(i)")
		}

		self.measure {
			var set = Set<Repository>()
			for repo in repos {
				set.insert(repo)
			}
		}
	}

	func testStringANSIStripPerformance() {
		let coloredStrings = (0..<1000).map { i in
			"\u{001B}[31mRepo\(i)\u{001B}[0m"
		}

		self.measure {
			for coloredString in coloredStrings {
				_ = coloredString.withoutANSIEscapeCodes
			}
		}
	}

	func testUIRendererColumnWidthCalculation() {
		let repos = (0..<500).map { i in
			let repo = Repository(name: "Repository\(i)WithLongName", path: "/test/repo/with/long/path/\(i)")
			repo.branch = "feature/super-long-branch-name-\(i)"
			repo.ahead = "999"
			repo.behind = "999"
			repo.changes = "999"
			repo.colorState = true
			return repo
		}

		let renderer = UIRenderer()
		self.measure {
			_ = renderer.render(repositories: repos, useANSIColors: true)
		}
	}

	func testRepositoryStateUpdates() {
		let repo = Repository(name: "TestRepo", path: "/test/repo")

		self.measure {
			for i in 0..<1000 {
				repo.branch = "branch-\(i)"
				repo.ahead = "\(i)"
				repo.behind = "\(i)"
				repo.changes = "\(i)"
			}
		}
	}
}
