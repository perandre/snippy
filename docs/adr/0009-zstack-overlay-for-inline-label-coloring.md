# ADR 0009 — ZStack overlay for inline label coloring

**Date:** 2026-04-13  
**Status:** Accepted

## Context

When a user types `Label: value` in the add or edit field, Snippy highlights the label portion in a distinct colour in real time (accent blue in add mode, orange in edit mode). The challenge is that SwiftUI's `TextField` does not support attributed strings or partial text colouring — the entire field has a single `foregroundColor`.

Three approaches were considered:

- **NSViewRepresentable wrapping NSTextField with NSAttributedString** — allows per-character styling but requires bridging AppKit's `NSTextField` into SwiftUI, handling focus, bindings, and attributed string updates manually. Significant complexity for a cosmetic feature.
- **SwiftUI `Text` with `AttributedString`** — `Text` supports `AttributedString` for inline styling, but `TextField` does not accept `AttributedString` as its binding value. Using a `Text` as a read-only display would lose editability.
- **ZStack with invisible TextField and visible styled Text overlay** — render the `TextField` with `.foregroundColor(.clear)` so the text is invisible but the cursor and selection remain functional. Layer a styled `Text` view on top using `Text(label).foregroundColor(.accent) + Text(": ") + Text(value)` to show the coloured rendering. Disable hit testing on the overlay with `.allowsHitTesting(false)` so clicks and selections go through to the underlying TextField.

## Decision

Use the ZStack overlay approach. Both `AddSnippetRow` and `EditSnippetRow` implement it identically:

```swift
ZStack(alignment: .leading) {
    TextField("placeholder", text: $input)
        .foregroundColor(parsed != nil ? .clear : .primary)
    if let p = parsed {
        (Text(p.label).foregroundColor(.accentColor)
         + Text(": ").foregroundColor(.secondary)
         + Text(p.value).foregroundColor(.primary))
            .allowsHitTesting(false)
    }
}
```

When `SnippyParser.parse(input)` returns `nil` (no valid label detected), the TextField uses its normal `.primary` foreground colour and no overlay is shown. When a label is detected, the TextField goes clear and the overlay renders the styled version.

## Consequences

- The coloured label preview updates on every keystroke with no perceptible lag, since `SnippyParser.parse` is a pure function with negligible cost.
- The TextField remains fully interactive — cursor positioning, text selection, and keyboard input work normally because the overlay has hit testing disabled.
- The overlay and the hidden text must use the same font and alignment; any mismatch causes visible misalignment between the cursor and the rendered text. Both rows use `.font(.system(size: 13, weight: .medium, design: .monospaced))` consistently.
- Monospaced font is critical: proportional fonts would cause the overlay characters to drift from the invisible TextField characters, making the cursor appear in the wrong position.
- The approach is purely visual — the underlying `input` binding contains the raw unstyled string. `SnippyParser` handles the actual split when saving.
