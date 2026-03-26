# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
swift build              # Debug build
bash build.sh            # Release build + install to /Applications/Snippy.app
open /Applications/Snippy.app
```

`build.sh` kills the running instance, builds release, creates the .app bundle, and copies it to /Applications.

No external dependencies. Requires macOS 14+ and Xcode Command Line Tools.

## Architecture

Pure SwiftUI + AppKit menu bar app. No dock icon (`LSUIElement: true`), no network access.

**Entry flow:** `main.swift` → `NSApplication` with `.accessory` policy → `AppDelegate` creates:
- **NSStatusItem** (menu bar icon)
- **NSPanel** (floating window with SwiftUI `ContentView` via `NSHostingView`)
- **Carbon global hotkey** (⌥⌘V via `RegisterEventHotKey`)
- **NSEvent global monitor** (click-outside-to-dismiss)

**Data:** `SnippetStore` (ObservableObject) persists to `~/Library/Application Support/Snippy/snippets.json` + `images/` dir. Sorted by `useCount` descending.

**Images:** Stored as PNGs with UUID filenames. Copied to clipboard as `NSImage` objects.

## Key Pattern: NSEvent Monitors

Standard SwiftUI keyboard handlers (`.onSubmit`, `.onKeyPress`) **do not work** in `NSPanel` floating windows. All keyboard input uses `NSEvent.addLocalMonitorForEvents`:

- **ContentView** installs a local monitor for arrow keys, Enter, Esc, ⌘V, ⌘N, ⌘Q
- **ReturnKeyModifier** (`OnReturnKey`) provides a reusable `.onReturnKey {}` modifier for Add/Edit rows
- Return `nil` to consume the event, return `event` to let it propagate
- Key codes: 36=Return, 53=Esc, 126=Up, 125=Down, 9=V, 45=N, 12=Q

The ContentView monitor skips interception when `isAdding` or `editingID != nil` (Add/Edit rows have their own monitors).

## Key Pattern: Smart Label Parser

`SnippyParser.parse("Label: value")` splits input into label + value. Rules:
- Separator must be `": "` (colon + space)
- Label must contain at least one letter (rejects `10: 30`)
- Label must not start with `{`/`[` or contain `//` (preserves URLs, JSON)
- Only first `": "` splits — value can contain colons

Used in both AddSnippetRow and EditSnippetRow. For image snippets, edit mode only edits the label.

## Key Pattern: Inline Label Coloring

Add/Edit rows use a ZStack overlay: when the parser detects a label, the TextField text goes `.foregroundColor(.clear)` and a colored `Text` overlay renders the label portion in accent/orange color. `allowsHitTesting(false)` on the overlay keeps the TextField interactive.
