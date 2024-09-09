//
//  File.swift
//  
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

enum ShellError: Error {
	case executionFailed(String)
}

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

			process.terminationHandler = { process in
				let data = pipe.fileHandleForReading.readDataToEndOfFile()
				guard let output = String(data: data, encoding: .utf8) else {
					continuation.resume(throwing: ShellError.executionFailed("Failed to interpret process output"))
					return
				}
				continuation.resume(returning: (output.trimmingCharacters(in: .whitespacesAndNewlines), process.terminationStatus))
			}

			do {
				try process.run()
			} catch {
				continuation.resume(throwing: error)
			}
		}
	}
}
