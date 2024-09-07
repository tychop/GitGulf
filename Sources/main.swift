//
//  GitGulf
//
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

func run() async {
    // Get command line arguments
    let arguments = CommandLine.arguments

    // Ensure there's at least one argument beyond the command itself
    guard arguments.count > 1 else {
        print("No arguments provided. Usage: gitgulf [status|fetch|pull|development|master|main|-b branch|--version]")
        return
    }

    // Get the first argument (following the command itself)
    let argument = arguments[1]
    let app = GitGulf()

    if argument == "--version" {
        // Print the version number
        print("GitGulf version 0.1.0")
    } else if argument == "-b" {
        guard arguments.count > 2 else {
            print("Branch name not provided. Usage: gitgulf -b branch")
            return
        }
        let branchName = arguments[2]
        await app.checkout(branch: branchName)
    } else {
        switch argument {
        case "status":
            await app.status()
        case "fetch":
            await app.fetch()
        case "pull":
            await app.pull()
        case "development":
            await app.checkout(branch: "development")
        case "master":
            await app.checkout(branch: "main")
        case "main":
            await app.checkout(branch: "main")
        default:
            print("Invalid argument: \(argument). Usage: gitgulf [status|fetch|pull|development|master|main|-b branch|--version]")
        }
    }
}

print("")
await run()