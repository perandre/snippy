# ADR 0004 — Carbon RegisterEventHotKey for the global ⌥⌘V shortcut

**Date:** 2026-04-08  
**Status:** Accepted

## Context

Snippy must respond to ⌥⌘V from any application — even when Snippy itself is not the frontmost app. macOS offers several mechanisms for registering system-wide keyboard shortcuts:

- **`NSEvent.addGlobalMonitorForEvents(matching: .keyDown)`** — captures all key events globally, but Apple sandboxed apps require the Accessibility permission and the user must explicitly grant it in System Settings. The permission prompt is disruptive, and the feature is unavailable if the user denies it.
- **`MASShortcut` / `HotKey` (third-party libraries)** — thin wrappers around the same Carbon API used below. Introduce an external dependency for a single call site.
- **Carbon `RegisterEventHotKey` / `InstallEventHandler`** — a legacy C API available in the `Carbon.HIToolbox` framework that ships with macOS. Registers a hotkey at the OS level without requiring Accessibility permission. Works in accessory-policy apps and does not go through the responder chain.
- **`NSMenuItem` with a key equivalent** — only fires when the menu is open or when the app is active; not useful for a global trigger.

## Decision

Use the Carbon `RegisterEventHotKey` + `InstallEventHandler` pair from `Carbon.HIToolbox`. The hotkey is registered in `AppDelegate.registerGlobalHotKey()` with a four-character signature (`SNPY`) and triggers `togglePanel()` via `DispatchQueue.main.async` to ensure the panel update happens on the main actor.

The hotkey is unregistered in `applicationWillTerminate(_:)` by calling `UnregisterEventHotKey`.

## Consequences

- No Accessibility permission is required. The shortcut works immediately after first launch.
- The Carbon API is marked as `@available(*, deprecated)` on Apple platforms but has not been removed and remains the recommended approach in Apple's own documentation for system-wide hotkeys in non-UI-element apps.
- The callback fires on a Carbon event handler thread; dispatching to `DispatchQueue.main` is required before touching any AppKit or SwiftUI state.
- Only one hotkey is registered. If the user wants to customise the shortcut, the app must be updated — there is no runtime reconfiguration today.
- The signature bytes (`0x534E5059` = `SNPY`) must be unique per application. They are not checked at runtime by macOS but collisions with other apps could cause silent failures.
