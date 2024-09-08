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

	private let spacer = "…"
	private let emptyString = ""
	private let titles: Titles = (repo: "Repository Name", branch: "Branch", ahead: "Ahead", behind: "Behind", changes: "Changes")
	private let colors = (
		red:         "\u{001B}[31m",
		purple:      "\u{001B}[35m",
		cyan:        "\u{001B}[36m",
		grey:        "\u{001B}[90m",
		brightGreen: "\u{001B}[92m",
		brightWhite: "\u{001B}[97m"
	)
	
	func render(repositories: [Repository], initialFrame: Bool = false) -> String {
		let sortedRepositories = repositories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

		let maxLengths: MaxLengths = (
			name: max(repositories.map { $0.name.count }.max() ?? 0, titles.repo.count),
			branch: max(repositories.map { $0.branch.count }.max() ?? 0, titles.branch.count),
			ahead: max(repositories.map { $0.ahead.count }.max() ?? 0, titles.ahead.count),
			behind: max(repositories.map { $0.behind.count }.max() ?? 0, titles.behind.count),
			changes: max(repositories.map { $0.changes.count }.max() ?? 0, titles.changes.count)
		)

		var resultString = ""

		self.renderHeader(&resultString, titles, maxLengths)
		self.renderDivider(&resultString, maxLengths)
		self.renderData(sortedRepositories, maxLengths, &resultString)

		return resultString
	}

	private func renderHeader(_ resultString: inout String, _ titles: Titles, _ maxLengths: MaxLengths) {
		resultString.append(
			"\(colors.brightWhite)\(titles.repo.padding(toLength: maxLengths.name, withPad: " ", startingAt: 0)) │ \(colors.grey)" +
			"\(colors.brightWhite)\(titles.branch.padding(toLength: maxLengths.branch, withPad: " ", startingAt: 0)) │ \(colors.grey)" +
			"\(colors.brightWhite)\(titles.ahead.padding(toLength: maxLengths.ahead, withPad: " ", startingAt: 0)) │ \(colors.grey)" +
			"\(colors.brightWhite)\(titles.behind.padding(toLength: maxLengths.behind, withPad: " ", startingAt: 0)) │ \(colors.grey)" +
			"\(colors.brightWhite)\(titles.changes.padding(toLength: maxLengths.changes, withPad: " ", startingAt: 0))\(colors.grey)\n"
		)
	}

	private func renderDivider(_ resultString: inout String, _ maxLengths: MaxLengths) {
		resultString.append(
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.name, withPad: "═", startingAt: 0))═╪═\(colors.grey)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.branch, withPad: "═", startingAt: 0))═╪═\(colors.grey)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.ahead, withPad: "═", startingAt: 0))═╪═\(colors.grey)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.behind, withPad: "═", startingAt: 0))═╪═\(colors.grey)" +
			"\(colors.brightWhite)\(emptyString.padding(toLength: maxLengths.changes, withPad: "═", startingAt: 0))\(colors.grey)\n"
		)
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

		if repo.colored == false {
			branchColor = colors.grey
		}

		let paddedBranch = repo.branch.padding(toLength: maxLength, withPad: spacer, startingAt: 0).replacingFirstOccurrence(of: spacer, with: " ")
		return "\(branchColor)\(paddedBranch.prefix(repo.branch.count))\(colors.grey)\(paddedBranch.dropFirst(repo.branch.count))"
	}

	private func aheadValue(repo: Repository, maxLengths: UIRenderer.MaxLengths, color: String) -> String {
		return repo.ahead == "0"
		? colors.grey + String(repeating: spacer, count: maxLengths.ahead)
		: padLeftConditional(repo.ahead, toLength: maxLengths.ahead, foregroundColor: color, resetColor: colors.grey, withPad: spacer)
	}
	
	private func behindValue(repo: Repository, maxLengths: UIRenderer.MaxLengths, color: String) -> String {
		return repo.behind == "0"
		? colors.grey + String(repeating: spacer, count: maxLengths.behind)
		: padLeftConditional(repo.behind, toLength: maxLengths.behind, foregroundColor: color, resetColor: colors.grey, withPad: spacer)
	}
	
	private func changesValue(repo: Repository, maxLengths: UIRenderer.MaxLengths, color: String) -> String {
		return repo.changes == "0"
		? colors.grey + String(repeating: spacer, count: maxLengths.changes)
		: padLeftConditional(repo.changes, toLength: maxLengths.changes, foregroundColor: color, resetColor: colors.grey, withPad: spacer)
	}
	
	private func renderData(_ sortedRepositories: [Repository], _ maxLengths: MaxLengths, _ resultString: inout String) {
		for repository in sortedRepositories {
			var aheadColor = colors.purple
			var behindColor = colors.red
			var changesColor = colors.cyan

			if repository.colored == false {
				aheadColor = colors.grey
				behindColor = colors.grey
				changesColor = colors.grey
			}

			let repoName = repoName(repo: repository, maxLength: maxLengths.name)
			let branchName = branchName(repo: repository, maxLength: maxLengths.branch)
			let aheadValue = aheadValue(repo: repository, maxLengths: maxLengths, color: aheadColor)
			let behindValue = behindValue(repo: repository, maxLengths: maxLengths, color: behindColor)
			let changesValue = changesValue(repo: repository, maxLengths: maxLengths, color: changesColor)

			let ahead = "\(colors.brightWhite)\(aheadValue)\(colors.grey)"
			let behind = "\(colors.brightWhite)\(behindValue)\(colors.grey)"
			let changes = "\(colors.brightWhite)\(changesValue)\(colors.grey)"

			resultString.append(
				"\(repoName) \(colors.brightWhite)│\(colors.grey) " +
				"\(branchName) \(colors.brightWhite)│\(colors.grey) " +
				"\(ahead) \(colors.brightWhite)│\(colors.grey) " +
				"\(behind) \(colors.brightWhite)│\(colors.grey) " +
				"\(changes)\n"
			)
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
}
