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
	let usageString = "Usage: gitgulf [ status | fetch | pull | development | master | -b branch | --version ]"

	guard arguments.count > 1 else {
		print("No arguments provided. \(usageString)")
		return
	}
	
	let argument = arguments[1]
	let gitgulf = GitGulf()
	
	if argument == "--version" {
		print("GitGulf v0.1.5")
		print("https://github.com/tychop/GitGulf")
	} else if argument == "-b" {
		guard arguments.count > 2 else {
			print("Branch name not provided. Usage: gitgulf -b branch")
			return
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
		case "development":
			await gitgulf.checkout(branch: "development")
		case "master":
			await gitgulf.checkout(branch: "master")
		default:
			print("Invalid argument: \(argument). \(usageString)")
		}
		print("")
	}
}

print("")
await run()

