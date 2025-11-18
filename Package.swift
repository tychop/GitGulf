// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "gitgulf",
	platforms: [
		.macOS(.v12)     // Modern Swift concurrency requires macOS 12+
	],
	targets: [
		// Core library; contains all business logic
		.target(
			name: "GitGulfLib"
		),
		// CLI executable that uses the library
		.executableTarget(
			name: "gitgulf",
			dependencies: ["GitGulfLib"]
		),
		// Tests link against the library (not the executable)
		.testTarget(
			name: "GitGulfTests",
			dependencies: ["GitGulfLib"]
		),
	]
)
