//
//  UIRenderer.swift
//
//
//  Created by Tycho Pandelaar on 06/09/2024.
//  Copyright © 2024 Tycho Pandelaar. All rights reserved.
//

import Foundation

class UIRenderer {
	typealias Titles = (repo: String, branch: String, ahead: String, behind: String, changes: String)
	typealias MaxLengths = (name: Int, branch: Int, ahead: Int, behind: Int, changes: Int)

	// UI Constants
	private let spacer = "…"
	private let emptyString = ""
	private let backgroundCharacter = " "
	private let verticalDivider = "│"
	private let intersection = "╪"
	private let horizontalDivider = "═"

	private let titles: Titles = (repo: "Repository Name", branch: "Branch", ahead: "Ahead", behind: "Behind", changes: "Changes")
	
	// Track whether to use ANSI colors
	private var useANSIColors: Bool = true
	
	private var colors: (red: String, purple: String, cyan: String, grey: String, brightGreen: String, brightWhite: String) {
		if useANSIColors {
			return (
				red:         "\u{001B}[31m",
				purple:      "\u{001B}[35m",
				cyan:        "\u{001B}[36m",
				grey:        "\u{001B}[90m",
				brightGreen: "\u{001B}[92m",
				brightWhite: "\u{001B}[97m"
			)
		} else {
			return (
				red:         "",
				purple:      "",
				cyan:        "",
				grey:        "",
				brightGreen: "",
				brightWhite: ""
			)
		}
	}

	private var columnDivider: String {
		return "\(colors.brightWhite) \(verticalDivider) \(colors.grey)"
	}

	private var intersectionFormatted: String {
		return "\(colors.brightWhite)═\(intersection)═\(colors.grey)"
	}

	func render(repositories: [Repository], terminalWidth: Int = 80, useANSIColors: Bool = true) -> String {
		self.useANSIColors = useANSIColors
		let sortedRepositories = repositories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

		let maxLengths: MaxLengths = (
			name: max(repositories.map { $0.name.count }.max() ?? 0, titles.repo.count),
			branch: max(repositories.map { $0.branch.count }.max() ?? 0, titles.branch.count),
			ahead: max(repositories.map { $0.ahead.count }.max() ?? 0, titles.ahead.count),
			behind: max(repositories.map { $0.behind.count }.max() ?? 0, titles.behind.count),
			changes: max(repositories.map { $0.changes.count }.max() ?? 0, titles.changes.count)
		)

		var resultString = ""

		self.renderHeader(&resultString, titles, maxLengths, terminalWidth: terminalWidth)
		self.renderDivider(&resultString, maxLengths, terminalWidth: terminalWidth)
		self.renderData(sortedRepositories, maxLengths, &resultString, terminalWidth: terminalWidth)

		return resultString
	}

	private func renderLine(_ resultString: inout String, content: String, terminalWidth: Int) {
		let tableWidth = content.characterCountExcludingANSIEscapeCodes
		let fillerWidth = terminalWidth - tableWidth

		var line = content
		if fillerWidth > 0 {
			line.append(String(repeating: backgroundCharacter, count: fillerWidth))
		}

		line.append("\n")
		resultString.append(line)
	}

	private func formatColumnText(_ text: String, _ maxLength: Int, _ color: String) -> String {
		return "\(color)\(text.padding(toLength: maxLength, withPad: " ", startingAt: 0))\(colors.grey)"
	}

	private func formatDividerSection(_ length: Int) -> String {
		return "\(colors.brightWhite)\(emptyString.padding(toLength: length, withPad: horizontalDivider, startingAt: 0))═\(colors.grey)"
	}

	private func renderHeader(_ resultString: inout String, _ titles: Titles, _ maxLengths: MaxLengths, terminalWidth: Int) {
		let headerContent = formatColumnText(titles.repo, maxLengths.name, colors.brightWhite) +
		columnDivider +
		formatColumnText(titles.branch, maxLengths.branch, colors.brightWhite) +
		columnDivider +
		formatColumnText(titles.ahead, maxLengths.ahead, colors.brightWhite) +
		columnDivider +
		formatColumnText(titles.behind, maxLengths.behind, colors.brightWhite) +
		columnDivider +
		formatColumnText(titles.changes, maxLengths.changes, colors.brightWhite)

		renderLine(&resultString, content: headerContent, terminalWidth: terminalWidth)
	}

	private func renderDivider(_ resultString: inout String, _ maxLengths: MaxLengths, terminalWidth: Int) {
		let dividerContent = formatDividerSection(maxLengths.name - 1) +
		intersectionFormatted +
		formatDividerSection(maxLengths.branch - 1) +
		intersectionFormatted +
		formatDividerSection(maxLengths.ahead - 1) +
		intersectionFormatted +
		formatDividerSection(maxLengths.behind - 1) +
		intersectionFormatted +
		formatDividerSection(maxLengths.changes - 1)

		renderLine(&resultString, content: dividerContent, terminalWidth: terminalWidth)
	}

	private func repoName(repo: Repository, maxLength: Int) -> String {
		let paddedRepoName = repo.name.padding(toLength: maxLength, withPad: spacer, startingAt: 0).replacingFirstOccurrence(of: spacer, with: " ")
		return "\(colors.brightWhite)\(paddedRepoName.prefix(repo.name.count))\(colors.grey)\(paddedRepoName.dropFirst(repo.name.count))"
	}

	private func branchName(repo: Repository, maxLength: Int) -> String {
		var branchColor = repo.ahead != "0" ? colors.purple
		: (repo.behind != "0" ? colors.red
			 : (repo.changes != "0" ? colors.cyan
					: colors.brightGreen))

		if repo.colorState == false {
			branchColor = colors.grey
		}

		let paddedBranch = repo.branch.padding(toLength: maxLength, withPad: spacer, startingAt: 0).replacingFirstOccurrence(of: spacer, with: " ")
		return "\(branchColor)\(paddedBranch.prefix(repo.branch.count))\(colors.grey)\(paddedBranch.dropFirst(repo.branch.count))"
	}

	private func renderData(_ sortedRepositories: [Repository], _ maxLengths: MaxLengths, _ resultString: inout String, terminalWidth: Int) {
		for repository in sortedRepositories {
			var aheadColor = colors.purple
			var behindColor = colors.red
			var changesColor = colors.cyan

			if repository.colorState == false {
				aheadColor = colors.grey
				behindColor = colors.grey
				changesColor = colors.grey
			}

			let repoNameText = repoName(repo: repository, maxLength: maxLengths.name)
			let branchNameText = branchName(repo: repository, maxLength: maxLengths.branch)

			let aheadValueText = repository.ahead == "0"
			? colors.grey + String(repeating: spacer, count: maxLengths.ahead)
			: padLeftConditional(repository.ahead, toLength: maxLengths.ahead, foregroundColor: aheadColor, resetColor: colors.grey, withPad: spacer)

			let behindValueText = repository.behind == "0"
			? colors.grey + String(repeating: spacer, count: maxLengths.behind)
			: padLeftConditional(repository.behind, toLength: maxLengths.behind, foregroundColor: behindColor, resetColor: colors.grey, withPad: spacer)

			let changesValueText = repository.changes == "0"
			? colors.grey + String(repeating: spacer, count: maxLengths.changes)
			: padLeftConditional(repository.changes, toLength: maxLengths.changes, foregroundColor: changesColor, resetColor: colors.grey, withPad: spacer)

			let content = "\(repoNameText) \(colors.brightWhite)\(verticalDivider)\(colors.grey) " +
			"\(branchNameText) \(colors.brightWhite)\(verticalDivider)\(colors.grey) " +
			"\(aheadValueText) \(colors.brightWhite)\(verticalDivider)\(colors.grey) " +
			"\(behindValueText) \(colors.brightWhite)\(verticalDivider)\(colors.grey) " +
			"\(changesValueText)"

			renderLine(&resultString, content: content, terminalWidth: terminalWidth)
		}
	}

	private func padLeftConditional(_ string: String, toLength newLength: Int, foregroundColor: String, resetColor: String, withPad spacer: String) -> String {
		resetColor + String(repeating: spacer, count: max(newLength - string.count - 1, 0)) + " " + foregroundColor + string + resetColor
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

	var withoutANSIEscapeCodes: String {
		let pattern = "\u{1B}\\[.*?m"
		return self.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
	}

	var characterCountExcludingANSIEscapeCodes: Int {
		return withoutANSIEscapeCodes.count
	}
}
