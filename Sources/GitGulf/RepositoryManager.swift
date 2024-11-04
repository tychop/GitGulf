//
//  File.swift
//  
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

@MainActor
class RepositoryManager {
	var repositories: Set<Repository> = []

	func loadRepositories() async {
		do {
			let fileManager = FileManager.default
			let currentPath = fileManager.currentDirectoryPath
			let directories = try fileManager.contentsOfDirectory(atPath: currentPath)
			let currentPathURL = URL(fileURLWithPath: currentPath)

			await withTaskGroup(of: Void.self) { group in
				for directory in directories {
					group.addTask {
						await self.processDirectory(directory, currentPathURL: currentPathURL)
					}
				}
			}
		} catch {
			print("Failed to enumerate directories: \(error)")
		}
	}

	private func processDirectory(_ directory: String, currentPathURL: URL) async {
		let fileManager = FileManager.default
		let directoryURL = currentPathURL.appendingPathComponent(directory)

		var isDirectory: ObjCBool = false
		let isGitDirectory = fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) && isDirectory.boolValue && fileManager.fileExists(atPath: directoryURL.appendingPathComponent(".git").path)

		if isGitDirectory {
			let repository = Repository(name: directory, path: directoryURL.path)

			do {
				try await repository.status()
			} catch {
				print("Failed to get git status for \(repository.name): \(error)")
				exit(1)
			}
			repository.colorState = false

			self.repositories.insert(repository)
		}
	}
}
