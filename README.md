# Snippy

A minimal Mac menu bar app for storing and quickly copying text snippets and images. Pure SwiftUI, fully offline, no dependencies.

**172 KB** download. Zero network access.

## Install

Download **Snippy-arm64.dmg** from [Releases](https://github.com/perandre/snippy/releases), open it, and drag Snippy to Applications.

Or build from source:

```
git clone https://github.com/perandre/snippy.git
cd snippy
bash build.sh
cp -r .build/app/Snippy.app /Applications/
```

Requires macOS 14+ and Xcode Command Line Tools.

## Usage

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+V` | Toggle Snippy from anywhere |
| `Cmd+V` | Paste clipboard as new snippet (text or image) |
| `Cmd+N` | Add new snippet manually |
| `Up/Down` | Navigate snippets |
| `Enter` | Copy selected to clipboard |
| `Esc` | Dismiss window |
| `Cmd+Q` | Quit |

### Adding snippets

- **Paste**: Copy something, open Snippy, `Cmd+V` — done.
- **Manual**: `Cmd+N`, then type the value and hit Enter.
- **With a label**: Type `Label: value` — the part before `: ` becomes a searchable label (highlighted in real-time as you type).
- **Images**: Copy an image, `Cmd+V` — saved with thumbnail preview. Edit to add a searchable label.

### Smart label detection

The `label: value` parser won't break on URLs (`https://...`), times (`10:30`), JSON, or other colon-containing values. A label must contain letters and be followed by `: ` (colon + space).

## Security

- Zero network permissions — `NSAllowsArbitraryLoads: false`, no outbound connections
- Data stored in `~/Library/Application Support/Snippy/` with POSIX 600/700 permissions
- Menu bar only — no dock icon, no window chrome
- No telemetry, no analytics, no third-party code

## Architecture

~1,100 lines of Swift across 11 source files:

```
Sources/
  main.swift              App entry point
  SnippyApp.swift         Menu bar, global hotkey, floating panel
  ContentView.swift       Main UI, keyboard handling via NSEvent monitor
  SnippetRow.swift        Row display (text + image thumbnails)
  AddSnippetRow.swift     Inline add with real-time label coloring
  EditSnippetRow.swift    Inline edit (text + image labels)
  SnippetStore.swift      JSON persistence, image storage, CRUD
  Snippet.swift           Data model (text + optional image)
  SnippyParser.swift      Smart "label: value" parser
  ReturnKeyModifier.swift NSEvent-based Return key handler for NSPanel
```

Data is plain JSON + PNG files. No database, no frameworks, no dependencies beyond macOS SDK.

## License

MIT
