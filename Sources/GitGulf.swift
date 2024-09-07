//
//  GitGulf.swift
//
//
//  Created by Tycho Pandelaar on 07/09/2024.
//  Copyright © 2024 KLM. All rights reserved.
//

import Foundation

class GitGulf {
	private let startTime = Date()

	enum GitCommand {
		case status
		case fetch
		case pull
		case checkout(String)
	}

	private let composer = UIComposer()
	private let repositoryManager = RepositoryManager()

	// A serial queue to ensure that updateUI is only called one at a time
	private let uiUpdateQueue = DispatchQueue(label: "com.gitgulf.uiUpdateQueue")

	func run(gitCommand: GitCommand) async {
		await repositoryManager.loadRepositories()
		let repositories = repositoryManager.repositories

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
					}
					await MainActor.run {
						self.updateUI()
					}
				}
			}
		}

		await MainActor.run {
			self.updateUI(finalFrame: true)
		}
		print("\u{001B}[0m")
	}

	func moveCursorUp(nrOfLines: Int) {
		print("\u{1B}[\(nrOfLines)A", terminator: "")
	}

	func updateUI(initialFrame: Bool = false, finalFrame: Bool = false) {
		let frame = composer.generateUIString(repositories: repositoryManager.repositories, initialFrame: initialFrame)
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
}
