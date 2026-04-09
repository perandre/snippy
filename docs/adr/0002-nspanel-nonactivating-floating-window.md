# ADR 0002 — NSPanel with nonactivatingPanel for the snippet overlay

**Date:** 2026-04-07  
**Status:** Accepted

## Context

Snippy's UI must appear as a floating overlay above the currently active application when the user presses `⌥⌘V`. The window must:

- Receive keyboard input (search field, arrow keys, shortcuts).
- Not steal focus from the foreground app — the user should be able to dismiss Snippy and immediately continue typing in whichever app they were using.
- Remain visible above all other windows without the user having to switch apps.

macOS offers several window types:

- **NSWindow (default)** — becomes the key window and activates the owning application, which moves it to the foreground and interrupts the user's prior context.
- **NSPanel** — a secondary window type designed for tool palettes and utility overlays. When created with the `.nonactivatingPanel` style mask it can become key without activating its application.
- **NSPopover** — anchors to a status-bar button and auto-dismisses, but cannot be shown from a global hotkey without additional hacks and loses keyboard handling in the same way.

## Decision

Use `NSPanel` with the `.nonactivatingPanel` style mask, combined with `.isFloatingPanel = true` and `.level = .floating`. The panel is hosted in `AppDelegate.setupPanel()`.

`NSApp.activate(ignoringOtherApps: true)` is called on show so the panel can receive key events, but because the panel is non-activating the previous app is not moved to the background and regains focus automatically when the panel is dismissed.

## Consequences

- The snippet panel appears instantly over any app without context-switching side effects.
- `NSEvent.addLocalMonitorForEvents` must be used for all keyboard handling because standard SwiftUI keyboard responders (`.onSubmit`, `.onKeyPress`) do not fire reliably in non-activating panels.
- `hidesOnDeactivate` is set to `false` so the panel stays visible if the user briefly switches apps (e.g., to look something up) before dismissing.
- A global `NSEvent.addGlobalMonitorForEvents` watching for mouse clicks outside the panel is required to implement click-to-dismiss, since the panel does not receive the blur event automatically.
