//
//  File.swift
//  
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 KLM. All rights reserved.
//

import Foundation

enum ShellError: Error {
	case executionFailed(String)
}

// Shell utility to execute commands and capture their output
struct Shell {
	@discardableResult
	static func execute(_ args: String...) async throws -> (output: String, status: Int32) {
		return try await withCheckedThrowingContinuation { continuation in
			let process = Process()
			process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
			process.arguments = args

			let pipe = Pipe()
			process.standardOutput = pipe
			process.standardError = pipe

			process.terminationHandler = { _ in
				let data = pipe.fileHandleForReading.readDataToEndOfFile()
				guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
					continuation.resume(throwing: ShellError.executionFailed("Failed to interpret process output"))
					return
				}

				continuation.resume(returning: (output, process.terminationStatus))
			}

			do {
				try process.run()
			} catch {
				continuation.resume(throwing: error)
			}
		}
	}
}
