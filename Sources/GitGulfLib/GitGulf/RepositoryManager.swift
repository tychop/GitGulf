//
//  RepositoryManager.swift
//
//  Created by Tycho Pandelaar on 06/09/2024.
//

import Foundation

@MainActor
class RepositoryManager {
	var repositories: Set<Repository> = []
	
	func loadRepositories(currentDirectory: String? = nil) async {
		do {
			let fileManager = FileManager.default
			let currentPath = currentDirectory ?? fileManager.currentDirectoryPath
			let currentPathURL = URL(fileURLWithPath: currentPath)
			let directories = try fileManager.contentsOfDirectory(atPath: currentPath)
			
			await withTaskGroup(of: Void.self) { group in
				for directory in directories {
					group.addTask {
						await self.processDirectory(directory, currentPathURL: currentPathURL)
					}
				}
			}
		} catch {
			// Silently fail - don't disrupt output
		}
	}
	
	private func processDirectory(_ directory: String, currentPathURL: URL) async {
		let fileManager = FileManager.default
		
		// Skip hidden directories (starting with .)
		guard !directory.hasPrefix(".") else { return }
		
		let directoryURL = currentPathURL.appendingPathComponent(directory)
		
		var isDirectory: ObjCBool = false
		let exists = fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory)
		guard exists && isDirectory.boolValue else { return }
		
		// Check if it's a symlink (don't follow symlinks for repo discovery)
		do {
			let resourceValues = try directoryURL.resourceValues(forKeys: [.isSymbolicLinkKey])
			if resourceValues.isSymbolicLink == true {
				return // Skip symlinks
			}
		} catch {
			// If we can't determine, continue anyway
		}
		
		// Check for .git directory
		let gitPath = directoryURL.appendingPathComponent(".git").path
		guard fileManager.fileExists(atPath: gitPath) else { return }
		
		let repository = Repository(name: directory, path: directoryURL.path)
		
		do {
			try await repository.status()
		} catch {
			// Silently skip repos that can't be read
			return
		}
		repository.colorState = false
		
		self.repositories.insert(repository)
	}
}
