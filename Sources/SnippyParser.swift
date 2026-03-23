import Foundation

enum SnippyParser {
    struct Result: Equatable {
        let label: String
        let value: String
    }

    /// Parses "label: value" input. Returns nil if there's no valid label separator.
    ///
    /// Rules:
    /// - Separator must be ": " (colon followed by at least one space)
    /// - Label must be text (not start with {, [, or contain //)
    /// - Label must contain at least one letter (not pure numbers/symbols)
    /// - Only the FIRST ": " is used as separator (value can contain colons)
    static func parse(_ input: String) -> Result? {
        // Must contain ": " (colon + space)
        guard let range = input.range(of: ": ") else { return nil }

        let label = String(input[input.startIndex..<range.lowerBound])
            .trimmingCharacters(in: .whitespaces)
        let value = String(input[range.upperBound...])
            .trimmingCharacters(in: .whitespaces)

        // Label must not be empty
        guard !label.isEmpty else { return nil }

        // Value must not be empty
        guard !value.isEmpty else { return nil }

        // Label must contain at least one letter (rejects "10: 30", "123: 456")
        guard label.contains(where: { $0.isLetter }) else { return nil }

        // Label must not look like a protocol or path (rejects "https: //...")
        guard !label.contains("//") else { return nil }
        guard !label.hasPrefix("{") && !label.hasPrefix("[") else { return nil }

        return Result(label: label, value: value)
    }
}
