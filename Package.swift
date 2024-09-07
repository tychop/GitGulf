// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "gitgulf",
	platforms: [
		.macOS(.v10_15)  // Specify the minimum macOS version
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.executableTarget(
			name: "gitgulf"),
	]
)
