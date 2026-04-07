# Snippy — Suggestions

Improvement ideas surfaced during code review. Capped at 3 per night; ordered by estimated user impact.

---

## 1. Categories / folders for snippet organisation

**Why:** As a user's snippet library grows beyond ~30 entries, use-count sorting alone is not enough to stay organised. A user storing both work templates, personal info, and code snippets has no way to separate them today. Grouping snippets into named categories (or at minimum tagging them with a colour) would let users find the right snippet faster and keep the list manageable. The `category` key is already present in `Snippet.CodingKeys` but unused, signalling this was already anticipated.

**Effort:** M

**Files involved:**
- `Sources/Snippet.swift` — add `category: String?` property
- `Sources/SnippetStore.swift` — update `filtered(by:)` to filter by category; add category CRUD
- `Sources/ContentView.swift` — add a category picker or sidebar strip above the list
- `Sources/AddSnippetRow.swift`, `Sources/EditSnippetRow.swift` — expose category selection in add/edit rows

---

## 2. Confirm before delete (or provide undo)

**Why:** Deletion is currently instant and irreversible — there is no confirmation dialog and no undo. A snippet deleted by accident (e.g. clicking the trash icon instead of the pencil) is gone permanently, along with its image file on disk. For text snippets this is annoying; for images it is unrecoverable. A single-step undo (⌘Z) or a brief "Deleted — Undo" toast would eliminate this risk with minimal friction.

**Effort:** S

**Files involved:**
- `Sources/SnippetRow.swift` — add a confirmation step or emit a delete-with-undo event
- `Sources/ContentView.swift` — manage a short-lived undo stack (a single `deletedSnippet` state is enough)
- `Sources/SnippetStore.swift` — add a `restore(_:)` method that re-inserts a deleted snippet and its image file

---

## 3. iCloud sync via NSUbiquitousKeyValueStore or CloudKit

**Why:** Users who work across multiple Macs (e.g. a laptop and a desktop) currently have no way to share their snippet library. Manually copying `snippets.json` is the only option. `NSUbiquitousKeyValueStore` supports up to 1 MB of data with zero server infrastructure and would cover most text-only libraries. For image-heavy libraries, a lightweight CloudKit private database would be needed. Offering even the simpler key-value option would be a meaningful quality-of-life improvement for multi-device users.

**Effort:** L

**Files involved:**
- `Sources/SnippetStore.swift` — add a sync layer that mirrors saves to/from iCloud storage; handle merge conflicts (last-write-wins by `lastUsedAt` is probably sufficient)
- `Info.plist` — add `NSUbiquitousContainers` or CloudKit entitlement keys
- `Package.swift` / `build.sh` — may require a signed app identity and the iCloud capability in Xcode
