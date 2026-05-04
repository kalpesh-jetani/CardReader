import Foundation

struct CardTextParser: Sendable {

    func parse(lines: [String]) -> BusinessCard {
        var card = BusinessCard()
        var usedIndices = Set<Int>()

        // Email
        if let (idx, value) = firstMatch(in: lines, pattern: Self.emailPattern) {
            card.email = value
            usedIndices.insert(idx)
        }

        // All phone numbers — try to associate a label/name from adjacent line
        card.phoneContacts = extractPhoneContacts(from: lines, usedIndices: &usedIndices)

        // Website
        if let (idx, value) = firstMatch(in: lines, pattern: Self.websitePattern) {
            card.website = value
            usedIndices.insert(idx)
        }

        // Address
        if let (idx, value) = firstMatch(in: lines, pattern: Self.addressPattern) {
            card.address = value
            usedIndices.insert(idx)
        }

        // Remaining lines for name, title, company
        let remaining = unusedLines(lines, usedIndices: usedIndices)

        if let (origIdx, nameLine) = remaining.first(where: { looksLikeName($0.element) }) {
            card.name = nameLine.trimmingCharacters(in: .whitespaces)
            usedIndices.insert(origIdx)
        }

        let remaining2 = unusedLines(lines, usedIndices: usedIndices)
        if let (origIdx, titleLine) = remaining2.first(where: { looksLikeJobTitle($0.element) }) {
            card.jobTitle = titleLine.trimmingCharacters(in: .whitespaces)
            usedIndices.insert(origIdx)
        }

        let remaining3 = unusedLines(lines, usedIndices: usedIndices)
        card.company = remaining3.first?.element.trimmingCharacters(in: .whitespaces) ?? ""

        return card
    }

    // MARK: - Phone extraction

    private func extractPhoneContacts(from lines: [String], usedIndices: inout Set<Int>) -> [PhoneContact] {
        guard let regex = try? NSRegularExpression(pattern: Self.phonePattern) else { return [] }
        var contacts: [PhoneContact] = []

        for (idx, line) in lines.enumerated() {
            let nsLine = line as NSString
            let range = NSRange(location: 0, length: nsLine.length)
            let matches = regex.matches(in: line, range: range)

            for match in matches {
                guard let swiftRange = Range(match.range, in: line) else { continue }
                let number = String(line[swiftRange])

                // Look for a label on the same line (text before the number)
                let prefix = line[line.startIndex ..< swiftRange.lowerBound]
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                // Or look at the previous non-used line as a name label
                let prevLine = idx > 0 ? lines[idx - 1].trimmingCharacters(in: .whitespaces) : ""
                let label: String
                if !prefix.isEmpty {
                    label = prefix
                } else if !prevLine.isEmpty && !usedIndices.contains(idx - 1) && looksLikeNameLabel(prevLine) {
                    label = prevLine
                    usedIndices.insert(idx - 1)
                } else {
                    label = contacts.isEmpty ? "Primary" : "Secondary"
                }

                contacts.append(PhoneContact(name: label, number: number))
            }

            if !matches.isEmpty { usedIndices.insert(idx) }
        }

        return contacts
    }

    // MARK: - Patterns

    private static let emailPattern   = #"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"#
    private static let phonePattern   = #"[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?[-\s\.]?[0-9]{3,4}[-\s\.]?[0-9]{3,6}"#
    private static let websitePattern = #"(https?://|www\.)[^\s]+"#
    private static let addressPattern = #"\d+\s+\w+(Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Way|Place|Pl)"#

    private static let titleKeywords  = [
        "CEO", "CTO", "CFO", "COO", "Director", "Manager", "Engineer", "Developer",
        "Designer", "Consultant", "President", "VP", "Vice President", "Lead", "Head",
        "Founder", "Partner", "Associate", "Analyst", "Officer"
    ]

    // MARK: - Helpers

    private func firstMatch(in lines: [String], pattern: String) -> (Int, String)? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        for (idx, line) in lines.enumerated() {
            let range = NSRange(line.startIndex..., in: line)
            if let match = regex.firstMatch(in: line, range: range),
               let swiftRange = Range(match.range, in: line) {
                return (idx, String(line[swiftRange]))
            }
        }
        return nil
    }

    private func unusedLines(_ lines: [String], usedIndices: Set<Int>) -> [(origIdx: Int, element: String)] {
        lines.enumerated()
            .filter { !usedIndices.contains($0.offset) && !$0.element.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { (origIdx: $0.offset, element: $0.element) }
    }

    private func looksLikeName(_ line: String) -> Bool {
        let words = line.trimmingCharacters(in: .whitespaces).split(separator: " ")
        guard words.count >= 2, words.count <= 4 else { return false }
        return words.allSatisfy { word in
            guard let first = word.first, first.isUppercase else { return false }
            return word.allSatisfy { $0.isLetter || $0 == "-" }
        }
    }

    // A short line (≤4 words) composed only of letters — used as a phone label/name
    private func looksLikeNameLabel(_ line: String) -> Bool {
        let words = line.split(separator: " ")
        guard words.count >= 1, words.count <= 4 else { return false }
        return words.allSatisfy { $0.allSatisfy { $0.isLetter || $0 == "." || $0 == "-" } }
    }

    private func looksLikeJobTitle(_ line: String) -> Bool {
        let upper = line.uppercased()
        return Self.titleKeywords.contains { upper.contains($0.uppercased()) }
    }
}
