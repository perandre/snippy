import SwiftUI
import AppKit

struct EditSnippetRow: View {
    @ObservedObject var store: SnippetStore
    let snippet: Snippet
    @Binding var editingID: UUID?

    @State private var input: String
    /// When true the snippet originally had a non-empty title, so `input`
    /// was built by joining title + ": " + value. We store the original
    /// title length so that `saveChanges` can split at the correct
    /// position instead of re-parsing with `SnippyParser` (which would
    /// mis-split when the title itself contains ": ").
    @State private var originalTitleLength: Int?
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
            self._originalTitleLength = State(initialValue: nil)
        } else if snippet.title.isEmpty {
            self._input = State(initialValue: snippet.value)
            self._originalTitleLength = State(initialValue: nil)
        } else {
            let initial = "\(snippet.title): \(snippet.value)"
            self._input = State(initialValue: initial)
            self._originalTitleLength = State(initialValue: snippet.title.count)
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

            // When the snippet originally had a title we built the input
            // string as "title: value". The user may have edited the title
            // portion (including adding/removing characters), but the
            // ": " separator they see on screen is always the one we
            // inserted. If the *title itself* contained ": " (e.g.
            // "Note: Important") a naive re-parse with SnippyParser would
            // split at the wrong ": ", corrupting the title.
            //
            // To avoid this we only fall through to SnippyParser when the
            // snippet had no title originally (the user is assigning one
            // for the first time). When the snippet already had a title we
            // try to split at the separator we know about; if the user
            // deleted it we treat the whole input as a bare value.
            if originalTitleLength != nil {
                // Look for ": " — use the *last* occurrence so that
                // a title like "Note: Important" with a value "data"
                // ("Note: Important: data") splits correctly at the
                // final ": " rather than the first one.
                if let range = trimmed.range(of: ": ", options: .backwards) {
                    let title = String(trimmed[trimmed.startIndex..<range.lowerBound])
                        .trimmingCharacters(in: .whitespaces)
                    let value = String(trimmed[range.upperBound...])
                        .trimmingCharacters(in: .whitespaces)
                    if !title.isEmpty && !value.isEmpty {
                        updated.title = title
                        updated.value = value
                    } else {
                        updated.title = ""
                        updated.value = trimmed
                    }
                } else {
                    // User removed the separator — treat as bare value
                    updated.title = ""
                    updated.value = trimmed
                }
            } else if let p = SnippyParser.parse(trimmed) {
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
