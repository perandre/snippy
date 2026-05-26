# ADR 0008 — NSEvent local monitors for all keyboard input

**Date:** 2026-04-13  
**Status:** Accepted

## Context

Snippy's UI runs inside an `NSPanel` with `.nonactivatingPanel` style (see ADR 0002). In this configuration, SwiftUI's standard keyboard handling APIs — `.onSubmit`, `.onKeyPress`, and `@FocusState`-driven responders — do not fire reliably. The SwiftUI responder chain depends on the hosting window being a regular key window in an active application, which a non-activating panel is not.

The app needs to handle a substantial set of keyboard inputs:

- Arrow keys for snippet navigation (`↑`/`↓`)
- Return to copy the selected snippet
- Escape to dismiss the panel or cancel add/edit
- `⌘V` to paste a new snippet from the clipboard
- `⌘N` to start adding a new snippet
- `⌘Q` to quit
- Return inside add/edit rows to save

Two approaches were considered:

- **Subclass NSTextField and override `keyDown(_:)`** — requires dropping SwiftUI's `TextField` in favour of an AppKit text field wrapped in `NSViewRepresentable`. Increases code complexity and loses SwiftUI binding convenience.
- **`NSEvent.addLocalMonitorForEvents(matching: .keyDown)`** — installs a closure that intercepts key events before they reach the responder chain. Works regardless of focus state or window type. Returns `nil` to consume the event or the event itself to let it propagate.

## Decision

Use `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` for all keyboard handling. Three separate monitors are installed depending on context:

1. **ContentView** — handles navigation, copy, dismiss, paste, new, and quit. Installed on `onAppear`, removed on `onDisappear`. Skips interception when `isAdding` or `editingID != nil` (except Escape).
2. **ReturnKeyModifier (`OnReturnKey`)** — a reusable `ViewModifier` that monitors for the Return key only. Used by `AddSnippetRow` and `EditSnippetRow` to save on Enter.
3. The monitors are layered: when an add/edit row is active, its `OnReturnKey` monitor consumes Return before the ContentView monitor sees it; ContentView's monitor defers all other keys to the add/edit row's TextField.

Key codes are used directly (36 = Return, 53 = Escape, 126 = Up, 125 = Down, 9 = V, 45 = N, 12 = Q) rather than character matching, because `characters` can vary with keyboard layouts while key codes are layout-independent.

## Consequences

- Keyboard handling works identically in the non-activating panel as it would in a regular window.
- SwiftUI `TextField` remains usable for text input — the monitors only intercept specific key codes and pass everything else through.
- Adding a new keyboard shortcut requires knowing the key code and adding a case to the appropriate monitor's switch statement.
- Multiple monitors active at the same time can cause ordering issues if they both handle the same key code. The current design avoids this by having ContentView's monitor defer to add/edit monitors via the `isAdding`/`editingID` guard.
- The monitors must be explicitly removed on `onDisappear` to prevent leaks and ghost handlers.
