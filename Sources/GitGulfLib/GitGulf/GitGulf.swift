//
//  GitGulf.swift
//
//  Created by Tycho Pandelaar on 07/09/2024.
//

import Foundation
import Dispatch
#if os(Linux)
import Glibc
#else
import Darwin
#endif

enum GitCommand {
	case status
	case fetch
	case pull
	case rebase
	case checkout(String)
}

public class GitGulf: @unchecked Sendable {
	private let startTime = Date()
	private let composer = UIRenderer()
	@MainActor private lazy var repositoryManager = RepositoryManager()
	private let isInteractive: Bool = {
		let fd = Int32(STDOUT_FILENO)
		return isatty(fd) != 0
	}()
	
	public init() {}
	
	/// Returns the elapsed time since start with two decimal places
	private var formattedElapsedTime: String {
		String(format: "%.2f", Date().timeIntervalSince(startTime))
	}
	
	func run(gitCommand: GitCommand) async {
		await repositoryManager.loadRepositories()
		let repositories = await repositoryManager.repositories
		
		await MainActor.run {
			self.updateUI()
		}
		
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
					
					// Update UI immediately as this repo completes
					await MainActor.run { [weak self] in
						guard let self = self else { return }
						repository.colorState = true
						self.updateUI()
						// Explicitly flush output to ensure it appears immediately
						fflush(stdout)
					}
				}
			}
		}
		
		await MainActor.run {
			self.updateUI(finalFrame: true)
			// Flush final output
			fflush(stdout)
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
	
	public func status() async {
		print("GitGulf: Status check:\n")
		await run(gitCommand: .status)
		print("Status check took \(formattedElapsedTime) seconds to complete.")
	}
	
	public func fetch() async {
		print("GitGulf: Fetch operation:\n")
		await run(gitCommand: .fetch)
		print("Fetch operation took \(formattedElapsedTime) seconds to complete.")
	}
	
	public func pull() async {
		print("GitGulf: Pull operation:\n")
		await run(gitCommand: .pull)
		print("Pull operation took \(formattedElapsedTime) seconds to complete.")
	}
	public func rebase() async {
		print("GitGulf: Pull --rebase operation:\n")
		await run(gitCommand: .rebase)
		print("Pull --rebase operation took \(formattedElapsedTime) seconds to complete.")
	}
	
	public func checkout(branch: String) async {
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
