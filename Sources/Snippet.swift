import Foundation

struct Snippet: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var value: String
    var imageFileName: String?
    var createdAt: Date
    var lastUsedAt: Date?
    var useCount: Int

    var isImage: Bool { imageFileName != nil }

    enum CodingKeys: String, CodingKey {
        case id, title, value, imageFileName, createdAt, lastUsedAt, useCount, category
    }

    init(title: String, value: String, imageFileName: String? = nil) {
        self.id = UUID()
        self.title = title
        self.value = value
        self.imageFileName = imageFileName
        self.createdAt = Date()
        self.lastUsedAt = nil
        self.useCount = 0
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        value = try c.decode(String.self, forKey: .value)
        imageFileName = try c.decodeIfPresent(String.self, forKey: .imageFileName)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        lastUsedAt = try c.decodeIfPresent(Date.self, forKey: .lastUsedAt)
        useCount = try c.decode(Int.self, forKey: .useCount)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(value, forKey: .value)
        try c.encodeIfPresent(imageFileName, forKey: .imageFileName)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encodeIfPresent(lastUsedAt, forKey: .lastUsedAt)
        try c.encode(useCount, forKey: .useCount)
    }
}
