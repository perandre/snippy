# Changelog

All notable user-facing changes to Snippy are documented here.

## [1.1.0] — 2026-04-24

### Added
- App icon visible in Finder, app switcher, and right-click menus.

### Changed
- Removed in-app `⌘Q` shortcut to prevent accidental quit while typing; use right-click on the menu bar icon to quit instead.

### Fixed
- NSEvent monitor leaks in keyboard handlers that could degrade responsiveness over long sessions.

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
