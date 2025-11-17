//
//  GitGulf.swift
//
//
//  Created by Tycho Pandelaar on 07/09/2024.
//  Copyright © 2024 KLM. All rights reserved.
//

import Foundation

enum GitCommand {
	case status
	case fetch
	case pull
	case rebase
	case checkout(String)
}

class GitGulf {
	private let startTime = Date()
	private let composer = UIRenderer()
	@MainActor private lazy var repositoryManager = RepositoryManager()
	private let isInteractive: Bool = isatty(STDOUT_FILENO) != 0
	
	/// Returns the elapsed time since start with two decimal places
	private var formattedElapsedTime: String {
		String(format: "%.2f", Date().timeIntervalSince(startTime))
	}

	/// Terminal width determined lazily by running 'tput cols'
	private lazy var terminalWidth: Int = {
		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/bin/tput")
		process.arguments = ["cols"]

		let pipe = Pipe()
		process.standardOutput = pipe

		do {
			try process.run()
			process.waitUntilExit()

			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			if let output = String(data: data, encoding: .utf8),
				 let width = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)),
				 width > 0 {
				return width
			}
		} catch {
			// Keep default width if tput fails
		}

		return 80 // Default width if tput fails
	}()

	func run(gitCommand: GitCommand) async {
		await repositoryManager.loadRepositories()
		let repositories = await repositoryManager.repositories

	await withTaskGroup(of: Void.self) { group in
		for repository in repositories {
			group.addTask {
				do {
					switch gitCommand {
					case .status:
						try await repository.status()
					case .fetch:
						try await repository.fetch()
				case .pull:
					try await repository.pull()
				case .rebase:
					try await repository.rebase()
				case .checkout(let branch):
						try await repository.checkout(branch: branch)
					}
				} catch {
					// Silently fail - don't disrupt the UI output
				}

				await MainActor.run {
					repository.colorState = true
					self.updateUI()
				}
			}
		}
	}

		await MainActor.run {
			self.updateUI(finalFrame: true)
		}

		resetTerminalTextFormatting()
	}

	@MainActor func updateUI(finalFrame: Bool = false) {
		let frame = composer.render(repositories: Array(repositoryManager.repositories), useANSIColors: isInteractive)
		print(frame, terminator: "")
		if finalFrame == false && isInteractive {
			moveCursorUp(nrOfLines: frame.split(separator: "\n").count)
		} else if finalFrame == false {
			print("")
		}
	}

	func status() async {
		print("GitGulf: Status check:\n")
		await run(gitCommand: .status)
		print("Status check took \(formattedElapsedTime) seconds to complete.")
	}

	func fetch() async {
		print("GitGulf: Fetch operation:\n")
		await run(gitCommand: .fetch)
		print("Fetch operation took \(formattedElapsedTime) seconds to complete.")
	}

	func pull() async {
		print("GitGulf: Pull operation:\n")
		await run(gitCommand: .pull)
		print("Pull operation took \(formattedElapsedTime) seconds to complete.")
	}

	func rebase() async {
		print("GitGulf: Rebase operation:\n")
		await run(gitCommand: .rebase)
		print("Rebase operation took \(formattedElapsedTime) seconds to complete.")
	}

	func checkout(branch: String) async {
		print("GitGulf: Switched to branch \(branch):\n")
		await run(gitCommand: .checkout(branch))
		print("Switching to branch \(branch) took \(formattedElapsedTime) seconds to complete.")
	}

	func moveCursorUp(nrOfLines: Int) {
		print("\u{1B}[\(nrOfLines)A", terminator: "")
	}

	@MainActor func debugState() {
		let sortedRepositories = repositoryManager
			.repositories
			.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

		sortedRepositories.forEach { repository in
			print(
				repository.name,
				repository.branch,
				repository.ahead,
				repository.behind,
				repository.changes
			)
		}
	}

	func resetTerminalTextFormatting() {
		print("\u{001B}[0m")
	}
}
