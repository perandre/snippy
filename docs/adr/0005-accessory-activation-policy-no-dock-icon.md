# ADR 0005 — NSApplication accessory activation policy (no dock icon)

**Date:** 2026-04-08  
**Status:** Accepted

## Context

Snippy is a utility that lives in the menu bar and is summoned by a global hotkey. As a background utility it should not appear in the Dock or the application switcher (⌘Tab), because:

- Showing a Dock icon implies the app has a primary window that can be brought to the front — Snippy's panel is transient, not a document window.
- Appearing in the app switcher causes ⌘Tab to land on Snippy, which then tries to activate and may steal focus unexpectedly.
- A Dock icon adds visual noise inconsistent with the utility's role.

macOS provides three `NSApplication` activation policies:

| Policy | Dock icon | App switcher | Suitable for |
|--------|-----------|--------------|--------------|
| `.regular` | Yes | Yes | Standard apps |
| `.accessory` | No | No | Menu bar utilities |
| `.prohibited` | No | No | Login items / daemons (no UI) |

The `LSUIElement` key in `Info.plist` achieves the same result as `.accessory` for apps launched via Finder or the system, but setting the policy programmatically at startup is more explicit and works regardless of how the bundle is launched.

## Decision

Set `NSApplication.shared.setActivationPolicy(.accessory)` in `main.swift` before the run loop starts. `Info.plist` also sets `LSUIElement = YES` as a belt-and-suspenders measure so macOS Launch Services suppresses the Dock icon even before the app's `main` function executes.

## Consequences

- Snippy never appears in the Dock or ⌘Tab switcher.
- The only user-visible entry point is the menu bar icon and the global hotkey.
- Because Snippy is an accessory app, `NSApp.activate(ignoringOtherApps: true)` must be called explicitly each time the panel is shown so it can receive key events. Without this call the panel appears but typing goes to the previously active app.
- There is no standard "quit" mechanism (no Dock right-click menu). The app provides ⌘Q within the panel and a "Quit Snippy" item in the menu bar right-click menu.
