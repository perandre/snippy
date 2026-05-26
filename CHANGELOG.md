# Changelog

All notable user-facing changes to Snippy are documented here.

## [Unreleased]

## [1.1] — 2026-04-24

### Added
- App icon — Snippy now displays a proper application icon in the Finder, Dock (on drag), and About dialog instead of a generic blank.

### Changed
- Removed the in-app `⌘Q` keyboard shortcut to prevent accidental quits while typing. Quit Snippy via right-click on the menu bar icon instead.

### Fixed
- Image-heavy snippet lists no longer cause jank when scrolling — decoded images are now cached in memory after the first load.
- The click-outside-to-dismiss listener now only runs while the panel is visible, eliminating unnecessary background event processing.

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
