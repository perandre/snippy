# ADR 0007 — SnippyParser heuristics for label:value detection

**Date:** 2026-04-09  
**Status:** Accepted

## Context

Snippy lets users attach a searchable label to a snippet by typing `Label: value` in the add or edit field. The label is highlighted in a distinct colour in real time. The parser must decide, for any arbitrary string the user pastes or types, whether it contains a label separator or should be saved as a plain value.

The naive split on `:` would break on common real-world strings:

| String | Naive split result | Correct result |
|--------|-------------------|----------------|
| `https://example.com` | label=`https`, value=`//example.com` | no label (URL) |
| `10:30` | label=`10`, value=`30` | no label (time) |
| `{"key": "val"}` | label=`{"key"`, value=`"val"}` | no label (JSON) |
| `Email: me@example.com` | label=`Email`, value=`me@example.com` | correct label |

Two design options were considered:

- **Require explicit user intent** — e.g., a dedicated "Label" field separate from the value field. Eliminates ambiguity but adds UI complexity (two fields, two input steps) and breaks the single-field speed that makes Snippy fast.
- **Heuristic parser** — a single text field with a set of rejection rules applied to the candidate label before accepting a split. Keeps the UI simple and handles the common cases with a few guard clauses.

## Decision

Implement `SnippyParser.parse(_:)` with the following rules applied in order:

1. Split only on `": "` (colon + space, not bare colon) — eliminates bare numeric ratios and most URLs.
2. The candidate label must not be empty after trimming.
3. The candidate value must not be empty after trimming.
4. The label must contain at least one Unicode letter — rejects pure-numeric labels (`10`, `123`).
5. The label must not contain `//` — rejects protocol-relative URLs and path fragments.
6. The label must not start with `{` or `[` — rejects JSON/array literals that happen to contain `": "`.

Only the **first** `": "` is used as the separator, so values may freely contain colons (e.g., `Meeting notes: 10:00 AM — discuss roadmap`).

## Consequences

- The single-field UX is preserved: one keystroke flow for labelled and unlabelled snippets alike.
- The rules handle the most common false-positive patterns (URLs, timestamps, JSON) without user configuration.
- Edge cases remain: a label containing `//` that is not a URL (unusual) would be rejected. A JSON value with `": "` at the start (after a valid label prefix) would still parse incorrectly. These are rare enough not to warrant extra complexity.
- Both `AddSnippetRow` and `EditSnippetRow` share the same parser, so the real-time colour highlight and the saved label are always consistent.
- The parser is a pure function with no side effects, making it straightforward to unit test in isolation should a test target be added.
