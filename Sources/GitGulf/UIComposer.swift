//
//  UIComposer.swift
//
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

class UIComposer {
	private let spacer = "…"
	private let emptyString = ""
	private let colors = (
		brightGreen: "\u{001B}[92m",
		brightWhite: "\u{001B}[97m",
		cyan:        "\u{001B}[36m",
		grey:        "\u{001B}[90m",
		purple:      "\u{001B}[35m",
		red:         "\u{001B}[31m",
		reset:       "\u{001B}[90m"
	)

	func render(repositories: [Repository], initialFrame: Bool = false) -> String {
		let sortedRepositories = repositories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
		let titles = (repo: "Repository Name", branch: "Branch", ahead: "Ahead", behind: "Behind", changes: "Changes")
		let maxLengths = (
			name: max(repositories.map { $0.name.count }.max() ?? 0, titles.repo.count),
			branch: max(repositories.map { $0.branch.count }.max() ?? 0, titles.branch.count),
			ahead: max(repositories.map { $0.ahead.count }.max() ?? 0, titles.ahead.count),
			behind: max(repositories.map { $0.behind.count }.max() ?? 0, titles.behind.count),
			changes: max(repositories.map { $0.changes.count }.max() ?? 0, titles.changes.count)
		)

		var resultString = ""

		// Render the header
		resultString.append(
			"\(colors.brightWhite)\(titles.repo.padding(toLength: maxLengths.name, withPad: " ", startingAt: 0)) │ \(colors.reset)" +
			"\(colors.brightWhite)\(titles.branch.padding(toLength: maxLengths.branch, withPad: " ", startingAt: 0)) │ \(colors.reset)" +
			"\(colors.brightWhite)\(titles.ahead.padding(toLength: maxLengths.ahead, withPad: " ", startingAt: 0)) │ \(colors.reset)" +
			"\(colors.brightWhite)\(titles.behind.padding(toLength: maxLengths.behind, withPad: " ", startingAt: 0)) │ \(colors.reset)" +
			"\(colors.brightWhite)\(titles.changes.padding(toLength: maxLengths.changes, withPad: " ", startingAt: 0))\(colors.reset)\n"
		)

		// Render the divider
		resultString.append(
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.name, withPad: "═", startingAt: 0))═╪═\(colors.reset)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.branch, withPad: "═", startingAt: 0))═╪═\(colors.reset)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.ahead, withPad: "═", startingAt: 0))═╪═\(colors.reset)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.behind, withPad: "═", startingAt: 0))═╪═\(colors.reset)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.changes, withPad: "═", startingAt: 0))\(colors.reset)\n"
		)

		// Render the repo specific data
		for repo in sortedRepositories {
			var aheadColor = colors.purple, behindColor = colors.red, changesColor = colors.cyan
			var branchColor = repo.ahead != "0" ? colors.purple :
			(repo.behind != "0" ? colors.red :
				(repo.changes != "0" ? colors.cyan :
					colors.brightGreen))

			if repo.colored == false {
				branchColor = colors.grey
				aheadColor = colors.grey
				behindColor = colors.grey
				changesColor = colors.grey
			}

			let repoName = (colors.brightWhite + repo.name + " " + colors.reset)
				.padding(toLength: maxLengths.name + colors.brightWhite.count + colors.reset.count, withPad: spacer, startingAt: 0)

			let aheadValue = repo.ahead == "0"
			? colors.reset + String(repeating: spacer, count: maxLengths.ahead)
			: padLeftConditional(repo.ahead, toLength: maxLengths.ahead, foregroundColor: aheadColor, resetColor: colors.reset, withPad: spacer)

			let behindValue = repo.behind == "0"
			? colors.reset + String(repeating: spacer, count: maxLengths.behind)
			: padLeftConditional(repo.behind, toLength: maxLengths.behind, foregroundColor: behindColor, resetColor: colors.reset, withPad: spacer)

			let changesValue = repo.changes == "0"
			? colors.reset + String(repeating: spacer, count: maxLengths.changes)
			: padLeftConditional(repo.changes, toLength: maxLengths.changes, foregroundColor: changesColor, resetColor: colors.reset, withPad: spacer)

			let paddedBranch = repo.branch.padding(toLength: maxLengths.branch, withPad: spacer, startingAt: 0).replacingFirstOccurrence(of: spacer, with: " ")
			let branch = "\(branchColor)\(paddedBranch.prefix(repo.branch.count))\(colors.reset)\(paddedBranch.dropFirst(repo.branch.count))"

			let ahead = "\(colors.brightWhite)\(aheadValue)\(colors.reset)"
			let behind = "\(colors.brightWhite)\(behindValue)\(colors.reset)"
			let changes = "\(colors.brightWhite)\(changesValue)\(colors.reset)"

			resultString.append(
				"\(repoName) \(colors.brightWhite)│\(colors.reset) " +
				"\(branch) \(colors.brightWhite)│\(colors.reset) " +
				"\(ahead) \(colors.brightWhite)│\(colors.reset) " +
				"\(behind) \(colors.brightWhite)│\(colors.reset) " +
				"\(changes)\n"
			)
		}

		return resultString
	}

	private func padLeftConditional(_ string: String, toLength newLength: Int, foregroundColor: String, resetColor: String, withPad spacer: String) -> String {
		let padLength = newLength - string.count

		return resetColor + String(repeating: spacer, count: max(padLength - 1, 0)) + " " + foregroundColor + string + resetColor
	}
}

extension String {
	func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
		guard !target.isEmpty else { return self }

		if let range = self.range(of: target), range.lowerBound != self.startIndex {
			return self.replacingCharacters(in: range, with: replacement)
		}

		return self
	}
}
