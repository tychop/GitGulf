//
//  GitGulf
//
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

func run() async {
	let arguments = CommandLine.arguments
	let usageString = "Usage: gitgulf [ status | fetch | pull | rebase | development | master | -b branch | --version ]"

	guard arguments.count > 1 else {
		FileHandle.standardError.write("Error: No arguments provided. \(usageString)\n".data(using: .utf8) ?? Data())
		exit(1)
	}
	
	let argument = arguments[1]
	let gitgulf = GitGulf()
	
		if argument == "--version" {
			print("GitGulf v0.2.1")
			print("https://github.com/tychop/GitGulf")
	} else if argument == "-b" {
		guard arguments.count > 2 else {
			FileHandle.standardError.write("Error: Branch name not provided. Usage: gitgulf -b branch\n".data(using: .utf8) ?? Data())
			exit(1)
		}
		let branchName = arguments[2]
		await gitgulf.checkout(branch: branchName)
	} else {
		switch argument {
		case "status":
			await gitgulf.status()
		case "fetch":
			await gitgulf.fetch()
		case "pull":
			await gitgulf.pull()
		case "rebase":
			await gitgulf.rebase()
		case "development":
			await gitgulf.checkout(branch: "development")
		case "master":
			await gitgulf.checkout(branch: "master")
		default:
			FileHandle.standardError.write("Error: Invalid argument: \(argument). \(usageString)\n".data(using: .utf8) ?? Data())
			exit(1)
		}
		print("")
	}
}

print("")
await run()

