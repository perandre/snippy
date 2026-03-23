import Foundation
import SwiftUI
import AppKit

@MainActor
class SnippetStore: ObservableObject {
    @Published var snippets: [Snippet] = []

    private let fileURL: URL
    private let imagesDir: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let snippyDir = appSupport.appendingPathComponent("Snippy", isDirectory: true)
        try? FileManager.default.createDirectory(at: snippyDir, withIntermediateDirectories: true)
        self.fileURL = snippyDir.appendingPathComponent("snippets.json")
        self.imagesDir = snippyDir.appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)

        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o700],
            ofItemAtPath: snippyDir.path
        )

        load()
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            snippets = [
                Snippet(title: "Email", value: "your@email.com"),
                Snippet(title: "Phone", value: "+1 555-0123"),
            ]
            save()
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            snippets = try JSONDecoder().decode([Snippet].self, from: data)
        } catch {
            snippets = []
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(snippets)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: fileURL.path
            )
        } catch {}
    }

    func add(title: String, value: String) {
        let snippet = Snippet(title: title, value: value)
        snippets.insert(snippet, at: 0)
        save()
    }

    func addImage(_ image: NSImage) {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let pngData = bitmap.representation(using: .png, properties: [:]) else { return }

        let fileName = UUID().uuidString + ".png"
        let fileURL = imagesDir.appendingPathComponent(fileName)

        do {
            try pngData.write(to: fileURL)
            let snippet = Snippet(title: "", value: "[image]", imageFileName: fileName)
            snippets.insert(snippet, at: 0)
            save()
        } catch {}
    }

    func imageURL(for snippet: Snippet) -> URL? {
        guard let name = snippet.imageFileName else { return nil }
        let url = imagesDir.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func loadImage(for snippet: Snippet) -> NSImage? {
        guard let url = imageURL(for: snippet) else { return nil }
        return NSImage(contentsOf: url)
    }

    func update(_ snippet: Snippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index] = snippet
            save()
        }
    }

    func delete(_ snippet: Snippet) {
        // Clean up image file
        if let name = snippet.imageFileName {
            let url = imagesDir.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: url)
        }
        snippets.removeAll { $0.id == snippet.id }
        save()
    }

    func recordUse(_ snippet: Snippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index].useCount += 1
            snippets[index].lastUsedAt = Date()
            save()
        }
    }

    func filtered(by query: String) -> [Snippet] {
        let sorted = snippets.sorted { $0.useCount > $1.useCount }
        guard !query.isEmpty else { return sorted }
        let q = query.lowercased()
        return sorted.filter {
            $0.title.lowercased().contains(q) ||
            $0.value.lowercased().contains(q)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        snippets.move(fromOffsets: source, toOffset: destination)
        save()
    }
}
