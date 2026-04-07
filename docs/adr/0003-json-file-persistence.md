# ADR 0003 — Plain JSON file for snippet persistence

**Date:** 2026-04-07  
**Status:** Accepted

## Context

Snippy needs to persist user snippets (text strings, image filenames, use counts, timestamps) across launches. The data set is small — a typical user might have tens to a few hundred snippets — and is accessed only by a single process on the local machine.

Candidate storage approaches considered:

- **Core Data** — Apple's full ORM stack. Designed for larger, relational data sets. Adds significant framework complexity and a heavyweight stack (persistent store coordinator, managed object context, etc.) for a trivially simple schema.
- **SQLite (direct or via GRDB/FMDB)** — Appropriate for structured, queryable data. Introduces an external dependency or requires raw SQL, neither of which is warranted for a flat list of snippets.
- **UserDefaults** — Suitable for preferences but not designed for arbitrary user-generated content; has size limitations and is not intended as a general-purpose store.
- **Plain JSON in Application Support** — A single encoded file per the Codable protocol. Simple, human-readable, dependency-free, and trivially inspectable or backed up by users.

## Decision

Persist snippets as a single `snippets.json` file inside `~/Library/Application Support/Snippy/`, written by `JSONEncoder` and read by `JSONDecoder` through the `Codable` conformance on `Snippet`. Images are stored as individual PNG files in an `images/` subdirectory, referenced by UUID filename from the JSON record.

Writes use `.atomic` (write to a temp file and rename) to avoid corruption on crash, and `.completeFileProtection` to encrypt the file at rest when the device is locked. The directory and file are restricted to owner-only permissions (700/600) via `setAttributes`.

## Consequences

- The implementation is ~30 lines with no dependencies beyond Foundation.
- The JSON file is human-readable and can be backed up, inspected, or migrated by hand.
- Atomic writes prevent partial-write corruption but mean the entire file is rewritten on every change. For the expected data sizes (< 1 MB) this is imperceptible.
- There is no migration system. Schema changes to `Snippet` must use `CodingKeys` with optional fields and sensible defaults so existing JSON files continue to decode.
- Concurrent access from multiple processes is not protected beyond the OS-level atomic rename. This is acceptable because Snippy runs as a single instance.
