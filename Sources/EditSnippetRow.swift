import SwiftUI
import AppKit

struct EditSnippetRow: View {
    @ObservedObject var store: SnippetStore
    let snippet: Snippet
    @Binding var editingID: UUID?

    @State private var input: String
    @FocusState private var isFocused: Bool

    private var parsed: SnippyParser.Result? {
        snippet.isImage ? nil : SnippyParser.parse(input)
    }

    init(store: SnippetStore, snippet: Snippet, editingID: Binding<UUID?>) {
        self.store = store
        self.snippet = snippet
        self._editingID = editingID

        if snippet.isImage {
            // For images, edit the label only
            self._input = State(initialValue: snippet.title)
        } else {
            let initial = snippet.title.isEmpty ? snippet.value : "\(snippet.title): \(snippet.value)"
            self._input = State(initialValue: initial)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.system(size: 14))

                if snippet.isImage {
                    TextField("Add a label...", text: $input)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .focused($isFocused)
                } else {
                    ZStack(alignment: .leading) {
                        TextField("label: value", text: $input)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(parsed != nil ? .clear : .primary)
                            .focused($isFocused)

                        if let p = parsed {
                            (Text(p.label).foregroundColor(.orange)
                             + Text(": ").foregroundColor(.secondary)
                             + Text(p.value).foregroundColor(.primary))
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .allowsHitTesting(false)
                        }
                    }
                }
            }

            // Show image preview when editing an image snippet
            if snippet.isImage, let img = store.loadImage(for: snippet) {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.leading, 22)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.orange.opacity(0.2), lineWidth: 1)
                )
        )
        .onReturnKey { saveChanges() }
        .onAppear {
            isFocused = true
        }
    }

    private func saveChanges() {
        let trimmed = input.trimmingCharacters(in: .whitespaces)

        var updated = snippet

        if snippet.isImage {
            // For images, input is just the label
            updated.title = trimmed
        } else {
            guard !trimmed.isEmpty else { return }
            if let p = SnippyParser.parse(trimmed) {
                updated.title = p.label
                updated.value = p.value
            } else {
                updated.title = ""
                updated.value = trimmed
            }
        }
        store.update(updated)
        editingID = nil
    }
}
