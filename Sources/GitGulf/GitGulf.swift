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
	case checkout(String)
}

class GitGulf {
	private let startTime = Date()
	private let composer = UIRenderer()
	@MainActor private lazy var repositoryManager = RepositoryManager()

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
						case .checkout(let branch):
							try await repository.checkout(branch: branch)
						}
					} catch {
						print("Failed to complete \(gitCommand) for \(repository.name): \(error)")
						exit(1)
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
		let frame = composer.render(repositories: Array(repositoryManager.repositories))
		print(frame)
		if finalFrame == false {
			moveCursorUp(nrOfLines: frame.split(separator: "\n").count + 1)
		}
	}

	func status() async {
		print("GitGulf: Status check\n")
		await run(gitCommand: .status)
		print("Status check took \(Date().timeIntervalSince(startTime)) seconds to complete")
	}

	func fetch() async {
		print("GitGulf: Fetch operation\n")
		await run(gitCommand: .fetch)
		print("Fetch operation took \(Date().timeIntervalSince(startTime)) seconds to complete")
	}

	func pull() async {
		print("GitGulf: Pull operation\n")
		await run(gitCommand: .pull)
		print("Pull operation took \(Date().timeIntervalSince(startTime)) seconds to complete")
	}

	func checkout(branch: String) async {
		print("GitGulf: Switching to branch \(branch)\n")
		await run(gitCommand: .checkout(branch))
		print("Switching to branch \(branch) took \(Date().timeIntervalSince(startTime)) seconds to complete")
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
