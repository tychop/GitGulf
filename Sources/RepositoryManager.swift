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
	private let repositoriesQueue = DispatchQueue(label: "com.gitgulf.repositoriesQueue", attributes: .concurrent)

	init() {}

	func loadRepositories() async {
		do {
			let fileManager = FileManager.default
			let currentPath = fileManager.currentDirectoryPath
			let directories = try fileManager.contentsOfDirectory(atPath: currentPath)

			await withTaskGroup(of: Void.self) { group in
				for directory in directories {
					// Avoid capturing FileManager directly
					var isDirectory: ObjCBool = false
					let path = currentPath + "/" + directory
					let isGitDirectory = fileManager.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue && fileManager.fileExists(atPath: "\(path)/.git")

					group.addTask {
						if isGitDirectory {
							let repository = Repository(name: directory, path: path)

							// Add to repositories in a thread-safe manner using DispatchWorkItem with barrier.
							let workItem = DispatchWorkItem(flags: .barrier) {
								self.repositories.append(repository)
							}
							self.repositoriesQueue.async(execute: workItem)
						}
					}
				}
			}
		} catch {
			print("Failed to enumerate directories: \(error)")
		}
	}
}
