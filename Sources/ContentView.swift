import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var store: SnippetStore
    var dismissAction: () -> Void

    @State private var searchText = ""
    @State private var selectedID: UUID?
    @State private var isAdding = false
    @State private var editingID: UUID?
    @State private var copiedID: UUID?
    @State private var hoveredID: UUID?
    @State private var keyMonitor: Any?

    var filteredSnippets: [Snippet] {
        store.filtered(by: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if filteredSnippets.isEmpty && !isAdding {
                emptyState
            } else {
                snippetList
            }

            Divider()

            footer
        }
        .frame(width: 380, height: 480)
        .background(.ultraThinMaterial)
        .onReceive(NotificationCenter.default.publisher(for: .snippyDidShow)) { _ in
            searchText = ""
            selectedID = filteredSnippets.first?.id
            isAdding = false
            editingID = nil
        }
        .onAppear { installKeyMonitor() }
        .onDisappear { removeKeyMonitor() }
    }

    // MARK: - Key Monitor

    /// NSEvent local monitor — works reliably in NSPanel windows
    private func installKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Don't intercept when add/edit row is active (they have their own monitor)
            if isAdding || editingID != nil {
                // But still handle Esc
                if event.keyCode == 53 { // Esc
                    if isAdding { isAdding = false }
                    else { editingID = nil }
                    return nil
                }
                return event
            }

            let cmd = event.modifierFlags.contains(.command)

            switch event.keyCode {
            case 126: // Up arrow
                moveSelection(by: -1)
                return nil
            case 125: // Down arrow
                moveSelection(by: 1)
                return nil
            case 36: // Return — copy selected
                copySelected()
                return nil
            case 53: // Esc — dismiss
                dismissAction()
                return nil
            case 9 where cmd: // ⌘V — paste new snippet
                pasteAsNewSnippet()
                return nil
            case 45 where cmd: // ⌘N — new snippet
                startAdding()
                return nil
            case 12 where cmd: // ⌘Q — quit
                NSApp.terminate(nil)
                return nil
            default:
                return event
            }
        }
    }

    private func removeKeyMonitor() {
        if let m = keyMonitor {
            NSEvent.removeMonitor(m)
            keyMonitor = nil
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 13))
            TextField("Search snippets...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text(searchText.isEmpty ? "No snippets yet" : "No matches")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            if searchText.isEmpty {
                Text("⌘V to paste from clipboard")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Snippet List

    private var snippetList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    if isAdding {
                        AddSnippetRow(store: store, isAdding: $isAdding)
                            .id("add-row")
                    }

                    ForEach(filteredSnippets) { snippet in
                        if editingID == snippet.id {
                            EditSnippetRow(
                                store: store,
                                snippet: snippet,
                                editingID: $editingID
                            )
                        } else {
                            SnippetRow(
                                snippet: snippet,
                                isSelected: selectedID == snippet.id,
                                isCopied: copiedID == snippet.id,
                                isHovered: hoveredID == snippet.id,
                                image: snippet.isImage ? store.loadImage(for: snippet) : nil,
                                onCopy: { copySnippet(snippet) },
                                onEdit: { editingID = snippet.id },
                                onDelete: { store.delete(snippet) }
                            )
                            .id(snippet.id)
                            .onHover { isHovered in
                                hoveredID = isHovered ? snippet.id : nil
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .onChange(of: selectedID) { _, newValue in
                if let id = newValue {
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button(action: { startAdding() }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("New Snippet")
                }
                .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 10) {
                Text("↑↓ select")
                Text("↵ copy")
                Text("⌘Q quit")
            }
            .font(.system(size: 10, design: .monospaced))
            .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    private func startAdding() {
        withAnimation(.easeOut(duration: 0.2)) {
            isAdding = true
        }
    }

    private func pasteAsNewSnippet() {
        let pb = NSPasteboard.general

        // Check for image first
        if let image = NSImage(pasteboard: pb), image.isValid {
            store.addImage(image)
            return
        }

        // Then text
        guard let clip = pb.string(forType: .string),
              !clip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let trimmed = clip.trimmingCharacters(in: .whitespacesAndNewlines)
        if store.snippets.contains(where: { $0.value == trimmed }) { return }
        store.add(title: "", value: trimmed)
    }

    private func copySnippet(_ snippet: Snippet) {
        NSPasteboard.general.clearContents()

        if snippet.isImage, let image = store.loadImage(for: snippet) {
            NSPasteboard.general.writeObjects([image])
        } else {
            NSPasteboard.general.setString(snippet.value, forType: .string)
        }
        store.recordUse(snippet)

        withAnimation(.easeOut(duration: 0.15)) {
            copiedID = snippet.id
        }

        // Flash green briefly, then clear — don't dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            copiedID = nil
        }
    }

    private func copySelected() {
        if let id = selectedID, let snippet = filteredSnippets.first(where: { $0.id == id }) {
            copySnippet(snippet)
        }
    }

    private func moveSelection(by offset: Int) {
        let list = filteredSnippets
        guard !list.isEmpty else { return }

        if let currentID = selectedID,
           let currentIndex = list.firstIndex(where: { $0.id == currentID }) {
            let newIndex = min(max(currentIndex + offset, 0), list.count - 1)
            selectedID = list[newIndex].id
        } else {
            selectedID = list.first?.id
        }
    }
}
