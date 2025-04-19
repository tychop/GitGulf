//
//  File.swift
//  
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

/// Errors that can occur during shell command execution
enum ShellError: Error, Sendable {
	/// The process execution failed with a specific reason
	case executionFailed(String)
	
	/// The process timed out
	case timeout(command: String, seconds: TimeInterval)
	
	/// The process was interrupted
	case interrupted(command: String)
	
	/// Failed to decode the output data
	case outputDecodingFailed
	
	/// The output buffer exceeded the maximum allowed size
	case outputTooLarge(maxBytes: Int)
	
	/// The working directory doesn't exist or isn't accessible
	case invalidWorkingDirectory(path: String)
	
	/// Error occurred while reading process output
	case outputReadError(String)
	
	/// Error occurred during process initialization
	case processSetupError(String)
}

/// Configuration options for shell command execution
struct ShellOptions: Sendable {
	/// Maximum execution time in seconds (nil means no timeout)
	var timeout: TimeInterval?
	
	/// Working directory for the command (nil means current directory)
	var workingDirectory: URL?
	
	/// Maximum output size in bytes (nil means no limit)
	var maxOutputSize: Int?
	
	/// Environment variables to use for the command (nil means inherit from parent process)
	var environment: [String: String]?
	
	/// Create default shell options
	static var `default`: ShellOptions {
		ShellOptions(
			timeout: 60.0,
			workingDirectory: nil,
			maxOutputSize: 10 * 1024 * 1024, // 10 MB
			environment: nil
		)
	}
}

/// A service for executing shell commands
struct Shell {
	/// Execute a shell command with the specified arguments
	/// - Parameters:
	///   - args: Command arguments, where the first argument is the command name
	///   - options: Configuration options for command execution
	/// - Returns: A tuple containing the command output and exit status
	@discardableResult
	static func execute(_ args: String..., options: ShellOptions = .default) async throws -> (output: String, status: Int32) {
		try await execute(args, options: options)
	}
	
	/// Execute a shell command with the specified arguments
	/// - Parameters:
	///   - args: Array of command arguments, where the first argument is the command name
	///   - options: Configuration options for command execution
	/// - Returns: A tuple containing the command output and exit status
	@discardableResult
	static func execute(_ args: [String], options: ShellOptions = .default) async throws -> (output: String, status: Int32) {
		try await ShellExecutor(args: args, options: options).execute()
	}
}

/// Private actor to manage shell command execution state
private actor ShellExecutor {
	// Command arguments and options
	private let args: [String]
	private let options: ShellOptions
	
	// Process management - these are isolated to the actor
	private let process = Process()
	private let inputPipe = Pipe()
	private let outputPipe = Pipe()
	private let errorPipe = Pipe()
	
	// Data collection - isolated buffer management
	private var outputData = Data()
	private var errorData = Data()
	private var totalBytesRead = 0
	
	// Execution state management
	private var isCompleted = false
	private var hasStarted = false
	private var timeoutTask: Task<Void, Never>? = nil
	private var monitorTask: Task<Void, Never>? = nil
	
	// Signal handling
	private var signalSource: DispatchSourceSignal? = nil
	
	// Continuation management - ensures we only resume once
	private var hasResumed = false
	
	// Command string for error reporting
	nonisolated var commandString: String {
		args.joined(separator: " ")
	}
	
	init(args: [String], options: ShellOptions) {
		self.args = args
		self.options = options
	}
	
	deinit {
		// Cannot use actor-isolated methods in deinit
		// Just cancel tasks directly
		timeoutTask?.cancel()
		monitorTask?.cancel()
		signalSource?.cancel()
		
		// Terminate process if still running
		if process.isRunning {
			process.terminate()
		}
	}
	
	// MARK: - Public Methods
	
	func execute() async throws -> (output: String, status: Int32) {
		return try await withCheckedThrowingContinuation { continuation in
			// Use a specific nonisolated task to coordinate execution
			Task {
				do {
					// Setup and validate process configuration
					try await setupProcess()
					
					// Setup signal handling (SIGINT)
					await setupSignalHandling(continuation: continuation)
					
					// Start process execution and monitoring
					try await startProcess(continuation: continuation)
				} catch {
					// Ensure proper cleanup on setup failure
					await markCompleted()
					await cleanupResources()
					
					// Only resume if not already resumed
					await resumeWithError(error, continuation: continuation)
				}
			}
		}
	}
	
	// MARK: - Process Setup
	
	private func setupProcess() async throws {
		// Configure process with command and arguments
		process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
		process.arguments = args
		
		// Configure working directory if provided
		if let workingDirectory = options.workingDirectory {
			// Verify working directory exists
			guard FileManager.default.fileExists(atPath: workingDirectory.path) else {
				throw ShellError.invalidWorkingDirectory(path: workingDirectory.path)
			}
			process.currentDirectoryURL = workingDirectory
		}
		
		// Configure environment variables if provided
		if let environment = options.environment {
			process.environment = environment
		}
		
		// Configure input/output pipes
		process.standardOutput = outputPipe
		process.standardError = errorPipe
		process.standardInput = inputPipe
	}
	
	private func setupSignalHandling(continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		// Create a dedicated serial queue for signal handling
		let signalQueue = DispatchQueue(label: "com.gitgulf.shell.signal")
		
		// Setup SIGINT signal handling
		signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: signalQueue)
		
		
		// Define a properly isolated @Sendable handler for interruption
		let interruptHandler: @Sendable () -> Void = { [weak self] in
			Task { [weak self] in
				guard let self = self else { return }
				
				// Call actor-isolated method to handle interruption
				await self.handleInterruption(continuation: continuation)
			}
		}
		
		// Set and activate the signal handler
		signalSource?.setEventHandler(handler: interruptHandler)
		signalSource?.resume()
	}
	
	// MARK: - Process Execution
	
	private func startProcess(continuation: CheckedContinuation<(output: String, status: Int32), Error>) async throws {
		// Mark the process as starting
		hasStarted = true
		
		// Set up timeout handler if timeout is specified
		if let timeout = options.timeout {
			await setupTimeout(timeout: timeout, continuation: continuation)
		}
		
		// Set up a properly @Sendable termination handler
		process.terminationHandler = { [weak self] process in
			guard let self = self else { return }
			
			// Use a Task to safely interact with the actor
			Task { [weak self] in
				guard let self = self else { return }
				
				// Call actor-isolated method to handle process termination
				await self.handleProcessTermination(process: process, continuation: continuation)
			}
		}
		
		do {
			// Start the process
			try process.run()
			
			// Close input pipe's write handle since we're not using it
			try inputPipe.fileHandleForWriting.close()
			
			// Start monitoring process output asynchronously
			monitorTask = Task {
				await monitorOutput(continuation: continuation)
			}
		} catch {
			// Wrap process start errors with more context
			throw ShellError.processSetupError("Failed to start process: \(error.localizedDescription)")
		}
	}
	
	// MARK: - Timeout Handling
	
	private func setupTimeout(timeout: TimeInterval, continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		timeoutTask = Task {
			do {
				// Wait for the specified timeout duration
				try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
				
				// Check if the task was cancelled
				if !Task.isCancelled {
					// Call actor-isolated method to handle timeout
					await self.handleTimeout(timeout: timeout, continuation: continuation)
				}
			} catch {
				// Ignore timeout sleep errors (like cancellation)
			}
		}
	}
	
	// MARK: - Output Monitoring
	private func monitorOutput(continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		do {
			while process.isRunning {
				// Since we're in an actor method, no need for await on property access
				if isCompleted { break }
				
				// Read data in chunks
				try await readOutputChunk()
				try await readErrorChunk()
				
				// Sleep briefly to avoid busy-waiting
				try await Task.sleep(nanoseconds: 100_000_000) // 100ms
			}
		} catch {
			// Since we're in an actor method, no need for await on property access
			if !isCompleted {
				await markCompleted()
				await cleanupResources()
				
				if error is CancellationError {
					// Task was cancelled normally, do nothing
					return
				}
				
				if let shellError = error as? ShellError {
					await resumeWithError(shellError, continuation: continuation)
				} else {
					await resumeWithError(ShellError.executionFailed(error.localizedDescription), continuation: continuation)
				}
			}
		}
	}
	
	private func readOutputChunk() async throws {
		let chunkSize = 4096
		let data = outputPipe.fileHandleForReading.readData(ofLength: chunkSize)
		if !data.isEmpty {
			outputData.append(data)
			
			// Check output size limit
			if let maxSize = options.maxOutputSize, outputData.count + errorData.count > maxSize {
				throw ShellError.outputTooLarge(maxBytes: maxSize)
			}
		}
	}
	
	private func readErrorChunk() async throws {
		let chunkSize = 4096
		let data = errorPipe.fileHandleForReading.readData(ofLength: chunkSize)
		if !data.isEmpty {
			errorData.append(data)
			
			// Check output size limit
			if let maxSize = options.maxOutputSize, outputData.count + errorData.count > maxSize {
				throw ShellError.outputTooLarge(maxBytes: maxSize)
			}
		}
	}
	
	private func finalizeExecution(process: Process) async throws -> (output: String, status: Int32) {
		// Read any remaining data
		try await readOutputChunk()
		try await readErrorChunk()
		
		// Combine output and error data
		let combinedData = outputData + errorData
		
		
		// Clean up resources
		await cleanupResources()
		// Convert output data to string
		guard let output = String(data: combinedData, encoding: .utf8) else {
			throw ShellError.outputDecodingFailed
		}
		
		return (output.trimmingCharacters(in: .whitespacesAndNewlines), process.terminationStatus)
	}
	
	// MARK: - State Management
	
	/// Mark the execution as completed and cancel any ongoing tasks
	private func markCompleted() async {
		isCompleted = true
		timeoutTask?.cancel()
		monitorTask?.cancel()
	}
	
	/// Resume continuation with success result, ensuring we only resume once
	private func resumeWithSuccess(output: String, status: Int32, continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		guard !hasResumed else { return }
		hasResumed = true
		continuation.resume(returning: (output, status))
	}
	
	/// Resume continuation with error, ensuring we only resume once
	private func resumeWithError(_ error: Error, continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		guard !hasResumed else { return }
		hasResumed = true
		continuation.resume(throwing: error)
	}
	
	// MARK: - Event Handlers
	
	/// Handle process interruption in an actor-isolated context
	private func handleInterruption(continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		// Check if already completed
		guard !isCompleted else { return }
		
		// Update state and clean up resources
		await markCompleted()
		await cleanupResources()
		
		// Resume with interrupted error
		await resumeWithError(
			ShellError.interrupted(command: commandString),
			continuation: continuation
		)
	}
	
	/// Handle process termination in an actor-isolated context
	private func handleProcessTermination(process: Process, continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		// Check if already completed
		guard !isCompleted else { return }
		
		// Mark as completed to prevent duplicate handling
		await markCompleted()
		
		do {
			// Read any remaining data and finalize
			let (output, status) = try await finalizeExecution(process: process)
			await resumeWithSuccess(output: output, status: status, continuation: continuation)
		} catch {
			await resumeWithError(error, continuation: continuation)
		}
	}
	
	/// Handle timeout in an actor-isolated context
	private func handleTimeout(timeout: TimeInterval, continuation: CheckedContinuation<(output: String, status: Int32), Error>) async {
		// Check if already completed
		guard !isCompleted else { return }
		
		// Mark as completed and clean up
		await markCompleted()
		await cleanupResources()
		
		// Resume with timeout error
		await resumeWithError(
			ShellError.timeout(command: commandString, seconds: timeout),
			continuation: continuation
		)
	}
	
	// MARK: - Resource Management
	
	private func cleanupResources() async {
		// Cancel any ongoing tasks
		timeoutTask?.cancel()
		monitorTask?.cancel()
		signalSource?.cancel()
		
		// Terminate process if still running
		if process.isRunning {
			process.terminate()
		}
		
		// Close all file handles safely
		do { try inputPipe.fileHandleForWriting.close() } catch {}
		do { try outputPipe.fileHandleForReading.close() } catch {}
		do { try errorPipe.fileHandleForReading.close() } catch {}
	}
}
