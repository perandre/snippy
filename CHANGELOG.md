# Changelog

All notable user-facing changes to Snippy are documented here.

## [Unreleased]

### Added
- App icon — Snippy now shows a proper icon in the menu bar, Dock (when visible), and Finder.

### Changed
- `⌘Q` shortcut removed to prevent accidental quits while typing; quit via right-click on the menu bar icon instead.
- Snippets with the same use count now sort by most recently used, so freshly added snippets appear in a more predictable position.

## [1.0.1] — 2026-03-26

### Changed
- Global shortcut changed from `⌘+Shift+V` to `⌥⌘V` to avoid conflicting with the system "Paste without formatting" shortcut.

## [1.0.0] — 2026-03-23

### Added
- Menu bar app with `⌥⌘V` global hotkey to toggle the snippet panel from anywhere.
- Store and copy text snippets and images (PNG) with `Cmd+V` paste-to-add.
- Smart `label: value` parser — type `Label: value` to attach a searchable label; real-time color highlight shows the label as you type.
- Keyboard-first navigation: `Up/Down` to move, `Enter` to copy, `Esc` to dismiss, `Cmd+N` to add manually, `Cmd+Q` to quit.
- Inline editing of snippet labels and text values.
- Image thumbnails in the snippet list; edit to add a searchable label.
- Snippets sorted by use count (most-used first).
- Fully offline — zero network access, data stored locally in `~/Library/Application Support/Snippy/`.
