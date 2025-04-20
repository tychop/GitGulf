//
//  Repository.swift
//  
//
//  Created by Tycho Pandelaar on 07/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

class Repository: Hashable {
	let name: String
	let path: String
	var branch: String
	var ahead: String
	var behind: String
	var changes: String

	let occurrencesOfBranchNamesToReplace = [
		"heads/",
		"remotes/",
		"remotes/o",
		"origin/",
		"tags/"
	]
	var colorState = false

	init(
		name: String,
		path: String,
		branch: String = "",
		ahead: String = "0",
		behind: String = "0",
		changes: String = "0"
	) {
		self.name = name
		self.path = path
		self.branch = branch
		self.ahead = ahead
		self.behind = behind
		self.changes = changes
	}

	func status() async throws {
		reset()
		
		branch = try await Shell.execute("git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD").output
		for occurrence in occurrencesOfBranchNamesToReplace {
			branch = branch.replacingOccurrences(of: occurrence, with: "")
		}

		let statusOutput = try await Shell.execute("git", "-C", path, "status", "--porcelain", "--branch").output
		if let aheadMatch = statusOutput.range(of: "ahead \\d+", options: .regularExpression) {
			ahead = statusOutput[aheadMatch].components(separatedBy: " ").last ?? "0"
		}
		if let behindMatch = statusOutput.range(of: "behind \\d+", options: .regularExpression) {
			behind = statusOutput[behindMatch].components(separatedBy: " ").last ?? "0"
		}

		let changesOutput = try await Shell.execute("git", "-C", path, "status", "-s").output.trimmingCharacters(in: .whitespacesAndNewlines)
		let nrOfChanges = changesOutput.split(separator: "\n").count
		if nrOfChanges > 0 {
			changes = "\(nrOfChanges)"
		}

		colorState = true
	}

	func checkout(branch: String) async throws {
		try await Shell.execute("git", "-C", path, "checkout", branch)
		try await finish()
	}

	func fetch() async throws {
		try await Shell.execute("git", "-C", path, "fetch")
		try await finish()
	}

	func pull() async throws {
		try await Shell.execute("git", "-C", path, "pull")
		try await finish()
	}

	func reset() {
		ahead = "0"
		behind = "0"
		changes = "0"
	}

	func finish() async throws {
		try await status()
	}

	// MARK: - Hashable Conformance

	static func == (lhs: Repository, rhs: Repository) -> Bool {
		return lhs.name == rhs.name
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
