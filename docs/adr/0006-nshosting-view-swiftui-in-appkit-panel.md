# ADR 0006 — NSHostingView to embed SwiftUI UI inside an AppKit NSPanel

**Date:** 2026-04-09  
**Status:** Accepted

## Context

Snippy uses an `NSPanel` as its floating overlay window (see ADR 0002). `NSPanel` is an AppKit class; its `contentView` property accepts an `NSView`. SwiftUI views, however, are declared as `View` conformances and cannot be set as a window's content view directly.

macOS provides two ways to bridge AppKit windows and SwiftUI UI:

- **`NSHostingController`** — a subclass of `NSViewController` that manages a SwiftUI view hierarchy as a view controller. Suitable when AppKit navigation patterns (parent/child view controllers, presentation APIs) are needed.
- **`NSHostingView`** — a concrete `NSView` subclass that renders a SwiftUI view hierarchy. Can be assigned directly to `NSWindow.contentView` without any view controller layer.

Snippy has no view controller hierarchy — the panel is a single floating overlay with one root view (`ContentView`). Adding `NSViewController` machinery would be boilerplate for no architectural benefit.

## Decision

Use `NSHostingView<ContentView>` as the panel's `contentView`. The hosting view is created in `AppDelegate.setupPanel()`, sized to match the panel frame, and assigned directly:

```swift
let hostingView = NSHostingView(rootView: content)
panel.contentView = hostingView
```

The `SnippetStore` `ObservableObject` is owned by `AppDelegate` and passed into `ContentView` at construction time, so SwiftUI's reactive update mechanism works normally.

## Consequences

- The entire UI is written in SwiftUI with no UIKit/AppKit view code beyond the bridge.
- `NSHostingView` participates in the AppKit responder chain, which is required for the local `NSEvent` key monitors installed in `ContentView` and `ReturnKeyModifier` to fire.
- SwiftUI's `@FocusState` does not reliably control first-responder status inside non-activating panels; `NSHostingView` provides no escape hatch for this. As a result, text field focus in `AddSnippetRow` and `EditSnippetRow` is managed by combining `@FocusState` (which works once the panel is active) with the `NSApp.activate` call in `showPanel()`.
- Resizing the panel at runtime would require manually updating `hostingView.frame`; current design uses a fixed 380×500 size so this is not an issue.
