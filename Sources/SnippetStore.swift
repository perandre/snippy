import Foundation
import SwiftUI
import AppKit

@MainActor
class SnippetStore: ObservableObject {
    @Published var snippets: [Snippet] = []

    private let fileURL: URL
    private let imagesDir: URL
    /// In-memory cache — keyed by imageFileName. NSCache evicts automatically
    /// under memory pressure, so this never grows unboundedly.
    private let imageCache = NSCache<NSString, NSImage>()

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
            // Prime the cache with the already-decoded image so the first
            // render after adding doesn't hit disk.
            imageCache.setObject(image, forKey: fileName as NSString)
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
        guard let name = snippet.imageFileName else { return nil }
        // Return cached copy if available.
        if let cached = imageCache.object(forKey: name as NSString) {
            return cached
        }
        // Fall back to disk and populate the cache.
        let url = imagesDir.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path),
              let image = NSImage(contentsOf: url) else { return nil }
        imageCache.setObject(image, forKey: name as NSString)
        return image
    }

    func update(_ snippet: Snippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index] = snippet
            save()
        }
    }

    func delete(_ snippet: Snippet) {
        // Clean up image file and cache entry.
        if let name = snippet.imageFileName {
            let url = imagesDir.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: url)
            imageCache.removeObject(forKey: name as NSString)
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
