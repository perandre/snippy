import SwiftUI

struct AddSnippetRow: View {
    @ObservedObject var store: SnippetStore
    @Binding var isAdding: Bool

    @State private var input = ""
    @FocusState private var isFocused: Bool

    private var parsed: SnippyParser.Result? {
        SnippyParser.parse(input)
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.accentColor)
                .font(.system(size: 14))

            ZStack(alignment: .leading) {
                TextField("value  or  label: value", text: $input)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(parsed != nil ? .clear : .primary)
                    .focused($isFocused)

                if let p = parsed {
                    (Text(p.label).foregroundColor(.accentColor)
                     + Text(": ").foregroundColor(.secondary)
                     + Text(p.value).foregroundColor(.primary))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
                )
        )
        .onReturnKey { saveSnippet() }
        .onAppear {
            isFocused = true
        }
    }

    private func saveSnippet() {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let p = SnippyParser.parse(trimmed) {
            store.add(title: p.label, value: p.value)
        } else {
            store.add(title: "", value: trimmed)
        }
        input = ""
        isAdding = false
    }
}
