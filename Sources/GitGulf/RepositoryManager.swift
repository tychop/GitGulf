//
//  File.swift
//  
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

class RepositoryManager {
	var repositories: [Repository] = []

	func loadRepositories() async {
		do {
			let fileManager = FileManager.default
			let currentPath = fileManager.currentDirectoryPath
			let directories = try fileManager.contentsOfDirectory(atPath: currentPath)
			let currentPathURL = URL(fileURLWithPath: currentPath)

			repositories = []

			await withTaskGroup(of: Void.self) { group in
				for directory in directories {
					let directoryURL = currentPathURL.appendingPathComponent(directory)

					var isDirectory: ObjCBool = false
					let isGitDirectory = fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) && isDirectory.boolValue && fileManager.fileExists(atPath: directoryURL.appendingPathComponent(".git").path)

					group.addTask {
						if isGitDirectory {
							let repository = Repository(name: directory, path: directoryURL.path)

							do {
								try await repository.status()
							} catch {
								print("Failed to get git status \(repository.name): \(error)")
								exit(1)
							}

							repository.colored = false
							self.repositories.append(repository)
						}
					}
				}
			}
		} catch {
			print("Failed to enumerate directories: \(error)")
		}
	}
}
