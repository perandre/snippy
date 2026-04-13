# ADR 0011 — ZStack overlay for real-time inline label coloring

**Date:** 2026-04-13  
**Status:** Accepted

## Context

Snippy's add and edit rows show a real-time color highlight as the user types: the label portion (before `": "`) appears in an accent color while the value portion stays in the primary color. This gives immediate visual feedback that the parser has detected a label, without requiring a separate label field.

SwiftUI's `TextField` does not support attributed strings or partial text coloring. The entire text field can have one `foregroundColor`, but there is no built-in way to color a substring differently.

Approaches considered:

- **NSTextField with NSAttributedString** — drop down to AppKit, use `NSMutableAttributedString` to set per-range colors. Works, but breaks SwiftUI's declarative data flow — the binding between `@State` and the attributed string must be managed manually, and the colored text must be re-applied on every keystroke.
- **Multiple adjacent TextFields** — split input into a label `TextField` and a value `TextField` side by side. Semantically clean but disrupts the single-field typing experience; the user would need to tab between fields and could not type `Label: value` in one continuous flow.
- **ZStack with transparent TextField + colored Text overlay** — keep a single `TextField` bound to the full input string, but set its `foregroundColor` to `.clear` when a label is detected. Layer a `Text` view on top (via `ZStack(alignment: .leading)`) that renders the label in accent color, the separator in secondary color, and the value in primary color. Disable hit-testing on the overlay so clicks and selections still reach the `TextField`.

## Decision

Use the ZStack overlay pattern in both `AddSnippetRow` and `EditSnippetRow`:

```swift
ZStack(alignment: .leading) {
    TextField("value  or  label: value", text: $input)
        .foregroundColor(parsed != nil ? .clear : .primary)

    if let p = parsed {
        (Text(p.label).foregroundColor(.accentColor)
         + Text(": ").foregroundColor(.secondary)
         + Text(p.value).foregroundColor(.primary))
            .allowsHitTesting(false)
    }
}
```

The overlay is conditionally shown only when `SnippyParser.parse(input)` returns a non-nil result. When no label is detected, the `TextField` renders normally with `.primary` color.

## Consequences

- The user types in a single field with no mode switches. Label detection is instant and non-disruptive — the colors update on every keystroke as SwiftUI re-evaluates the `parsed` computed property.
- `.allowsHitTesting(false)` on the overlay ensures the `TextField` remains fully interactive: cursor placement, text selection, and drag all work as expected because input events pass through the overlay.
- The `Text` overlay and the `TextField` must use identical font metrics (`.system(size: 13, weight: .medium, design: .monospaced)`) so the colored text aligns exactly with the invisible original text. A mismatch would cause visible misalignment.
- `AddSnippetRow` uses `.accentColor` for the label; `EditSnippetRow` uses `.orange`. This visual distinction helps the user tell at a glance whether they are adding or editing.
- The pattern works only for single-line text. If multi-line snippet editing were added, the overlay alignment would break because `Text` and `TextField` handle line wrapping differently.
- The cursor and selection highlight are rendered by the underlying `TextField` in its `.clear` foreground color — they remain visible because the cursor and selection use system colors, not the text foreground color.
