// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "gitgulf",
	platforms: [
		.macOS(.v12)
	],
	products: [
		.executable(name: "gitgulf", targets: ["gitgulf"]) 
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
		)
	]
)
