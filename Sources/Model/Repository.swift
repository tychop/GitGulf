//
//  Repository.swift
//  
//
//  Created by Tycho Pandelaar on 07/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

class Repository: Hashable, @unchecked Sendable {
	let name: String
	let path: String
	var branch: String
	var ahead: String
	var behind: String
	var changes: String
	var colorState = false
	
	private let stateQueue = DispatchQueue(label: "com.gitgulf.repository.state", attributes: .concurrent)

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
		
		let branchOutput = try await Shell.execute("git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD")
		guard branchOutput.status == 0 else {
			throw ShellError.executionFailed("Failed to get branch for \(name)")
		}
		stateQueue.async(flags: .barrier) { [weak self] in
			self?.branch = branchOutput.output
		}

		let statusOutput = try await Shell.execute("git", "-C", path, "status", "--porcelain", "--branch")
		guard statusOutput.status == 0 else {
			throw ShellError.executionFailed("Failed to get status for \(name)")
		}
		
		// Parse ahead/behind with better locale independence
		let lines = statusOutput.output.split(separator: "\n", omittingEmptySubsequences: true)
		if let firstLine = lines.first {
			let lineStr = String(firstLine)
			
			// Look for "ahead X" or "behind X" patterns
			if let aheadMatch = lineStr.range(of: "ahead\\s+\\d+", options: .regularExpression) {
				let matchStr = String(lineStr[aheadMatch])
				if let number = matchStr.split(separator: " ").last, let count = Int(number) {
					stateQueue.async(flags: .barrier) { [weak self] in
						self?.ahead = String(count)
					}
				}
			}
			
			if let behindMatch = lineStr.range(of: "behind\\s+\\d+", options: .regularExpression) {
				let matchStr = String(lineStr[behindMatch])
				if let number = matchStr.split(separator: " ").last, let count = Int(number) {
					stateQueue.async(flags: .barrier) { [weak self] in
						self?.behind = String(count)
					}
				}
			}
		}

		let changesOutput = try await Shell.execute("git", "-C", path, "status", "-s")
		guard changesOutput.status == 0 else {
			throw ShellError.executionFailed("Failed to get changes for \(name)")
		}
		
		let changesStr = changesOutput.output.trimmingCharacters(in: .whitespacesAndNewlines)
		let nrOfChanges = changesStr.isEmpty ? 0 : changesStr.split(separator: "\n").count
		if nrOfChanges > 0 {
			stateQueue.async(flags: .barrier) { [weak self] in
				self?.changes = "\(nrOfChanges)"
			}
		}

		stateQueue.async(flags: .barrier) { [weak self] in
			self?.colorState = true
		}
	}

	func checkout(branch: String) async throws {
		// Validate branch name to prevent command injection
		guard isValidBranchName(branch) else {
			throw ShellError.executionFailed("Invalid branch name: \(branch)")
		}
		
		do {
			let result = try await Shell.execute("git", "-C", path, "checkout", branch)
			guard result.status == 0 else {
				throw ShellError.executionFailed("Failed to checkout branch \(branch) for \(name): \(result.output)")
			}
			try await finish()
		} catch {
			throw ShellError.executionFailed("Checkout failed for \(name): \(error.localizedDescription)")
		}
	}

	func fetch() async throws {
		do {
			let result = try await Shell.execute("git", "-C", path, "fetch")
			guard result.status == 0 else {
				throw ShellError.executionFailed("Failed to fetch \(name): \(result.output)")
			}
			try await finish()
		} catch {
			throw ShellError.executionFailed("Fetch failed for \(name): \(error.localizedDescription)")
		}
	}

	func pull() async throws {
		do {
			let result = try await Shell.execute("git", "-C", path, "pull")
			guard result.status == 0 else {
				throw ShellError.executionFailed("Failed to pull \(name): \(result.output)")
			}
			try await finish()
		} catch {
			throw ShellError.executionFailed("Pull failed for \(name): \(error.localizedDescription)")
		}
	}

	func reset() {
		stateQueue.async(flags: .barrier) { [weak self] in
			self?.ahead = "0"
			self?.behind = "0"
			self?.changes = "0"
		}
	}

	func finish() async throws {
		try await status()
	}
	
	/// Validates branch names to prevent command injection
	private func isValidBranchName(_ name: String) -> Bool {
		// Branch names must not be empty
		guard !name.isEmpty else { return false }
		
		// Branch names cannot contain special shell characters
		let invalidChars = CharacterSet(charactersIn: ";|&$`\\\"'<>(){}[]!*?")
		let isValid = name.unicodeScalars.allSatisfy { !invalidChars.contains($0) }
		
		return isValid
	}

	// MARK: - Hashable Conformance

	static func == (lhs: Repository, rhs: Repository) -> Bool {
		return lhs.name == rhs.name
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
