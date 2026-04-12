# ADR 0009 — Use-count sorting as the default snippet order

**Date:** 2026-04-12  
**Status:** Accepted

## Context

Snippy needs a default ordering for the snippet list. The ordering determines which snippets the user sees first when the panel opens and directly affects how quickly they can find and copy the one they need.

Common ordering strategies for a personal snippet manager:

- **Chronological (newest first)** — intuitive after adding, but frequently used snippets sink to the bottom over time and require scrolling or searching.
- **Alphabetical** — predictable but bears no relation to usage frequency. A rarely used snippet starting with "A" always appears before a daily-use snippet starting with "Z".
- **Manual (drag to reorder)** — maximally flexible but requires the user to actively maintain the order. Becomes tedious as the library grows.
- **Frequency-based (most used first)** — the list self-organises around actual usage. Snippets the user copies often float to the top automatically, reducing navigation for the most common workflows.

## Decision

Sort snippets by `useCount` descending in `SnippetStore.filtered(by:)`. Every call to `copySnippet()` increments the snippet's `useCount` and records `lastUsedAt`, then persists via `save()`. The sorted order is recomputed on every access (no cached sort index).

New snippets start with `useCount = 0` and appear at the bottom of the list until they accumulate enough copies to rise. The `move(fromOffsets:toOffset:)` method exists in `SnippetStore` for potential future manual reordering but is not wired to any UI today.

## Consequences

- The most-copied snippets naturally appear at the top, which optimises for the common case (the user opens Snippy to copy something they copy often).
- Newly added snippets start at the bottom, which can be surprising. A user who just added a snippet must scroll or search to find it. This is a known trade-off; the `suggest-improvements` list includes a "pin/favourite" feature as a potential mitigation.
- Sorting is O(n log n) on every `filtered(by:)` call. For expected library sizes (tens to low hundreds of snippets) this is imperceptible.
- Ties in `useCount` are broken by the array's existing insertion order (newest first for equal counts), giving a reasonable secondary sort without extra logic.
- The `lastUsedAt` timestamp is recorded but not currently used for sorting. It is available for future features such as a recency-weighted score or a "last used" display.
