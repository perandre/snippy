# ADR 0008 — NSEvent local monitor for all keyboard input

**Date:** 2026-04-12  
**Status:** Accepted

## Context

Snippy's UI runs inside an `NSPanel` with the `.nonactivatingPanel` style mask (see ADR 0002). SwiftUI provides several built-in mechanisms for handling keyboard input:

- **`.onSubmit`** — fires when the user presses Return inside a focused `TextField`. In a standard `NSWindow` this works reliably.
- **`.onKeyPress` (macOS 14+)** — attaches a handler for arbitrary key events to any SwiftUI view.
- **`@FocusState` + `focused()` modifier** — manages first-responder state declaratively.

However, in non-activating `NSPanel` windows these mechanisms are unreliable. `.onSubmit` and `.onKeyPress` silently fail to fire because the SwiftUI responder chain does not always connect properly when the hosting window is non-activating. `@FocusState` may not update after the panel is hidden and reshown.

The alternative is to drop to AppKit and use `NSEvent.addLocalMonitorForEvents(matching: .keyDown)`, which intercepts key events at the application level before they enter the responder chain. This works regardless of window type.

## Decision

Use `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` for **all** keyboard handling throughout the app:

- **`ContentView`** installs a local monitor on appear for arrow keys (126/125), Return (36), Escape (53), `⌘V` (9), `⌘N` (45), and `⌘Q` (12). The monitor skips interception when `isAdding` or `editingID != nil` so it does not conflict with the add/edit row monitors.
- **`ReturnKeyModifier` (`OnReturnKey`)** provides a reusable `.onReturnKey {}` view modifier that installs its own local monitor scoped to the modifier's lifetime (`onAppear` / `onDisappear`). Used by `AddSnippetRow` and `EditSnippetRow`.
- Returning `nil` from the monitor callback consumes the event; returning the event lets it propagate to other responders.

## Consequences

- Keyboard shortcuts work identically whether the panel is first shown, reshown after hiding, or activated from a different app.
- Multiple monitors coexist: `ContentView`'s monitor yields to the add/edit monitors by checking `isAdding` / `editingID`, and each `OnReturnKey` monitor only intercepts keyCode 36. Care must be taken when adding new monitors to avoid double-handling.
- Raw key codes (integers) are used instead of symbolic constants, which is less readable. A comment next to each code documents the key name.
- Every monitor must be removed in `onDisappear` (or the equivalent cleanup path) to avoid leaking event taps. `ContentView` and `OnReturnKey` both follow this pattern.
- If a future macOS release fixes SwiftUI key handling in non-activating panels, the monitors could be replaced with declarative SwiftUI handlers. Until then, this approach is the most reliable option.
