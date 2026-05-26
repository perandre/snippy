# ADR 0010 — Swift Package Manager build with shell-script app bundling

**Date:** 2026-04-13  
**Status:** Accepted

## Context

Snippy is a macOS GUI application with an `NSPanel`, menu bar icon, and a full SwiftUI view hierarchy. macOS GUI apps are conventionally built with Xcode projects (`.xcodeproj` or `.xcworkspace`), which provide automatic app bundle creation, code signing, asset catalog compilation, and Interface Builder integration.

However, Snippy has no external dependencies, no asset catalogs, no storyboards, and no test target. The entire app is ~1,100 lines of Swift across 10 source files. An Xcode project for this scope is mostly boilerplate — the `.xcodeproj` directory alone would be larger than several source files combined.

Alternative approaches considered:

- **Xcode project** — full IDE integration and automatic `.app` bundle generation, but adds ~20 config files, merge-conflict-prone `pbxproj`, and requires Xcode (not just Command Line Tools) to build.
- **Swift Package Manager only** — builds an executable binary via `swift build`, but SPM has no concept of `.app` bundles, `Info.plist`, or macOS application packaging.
- **SPM + shell script** — SPM compiles the Swift code; a short shell script assembles the `.app` bundle structure, copies the binary and `Info.plist`, and optionally installs to `/Applications`.

## Decision

Use `Package.swift` (swift-tools-version 6.0, Swift language mode 5) as the build system and `build.sh` as the app-bundling step. The package defines a single executable target with all sources in `Sources/`. The shell script:

1. Runs `swift build -c release`.
2. Creates the `.app/Contents/MacOS` and `.app/Contents/Resources` directory structure.
3. Copies the compiled binary from `.build/release/Snippy` into the bundle.
4. Copies `Info.plist` into `.app/Contents/`.
5. Writes a `PkgInfo` file (`APPL????`).
6. Optionally kills any running instance and installs to `/Applications`.

## Consequences

- Building requires only Xcode Command Line Tools (`xcode-select --install`), not the full Xcode IDE. `swift build` works from any terminal.
- There is no `.xcodeproj` to maintain or merge. The `Package.swift` is 14 lines.
- Code signing is not handled. The app runs unsigned, which is fine for local development but means Gatekeeper will block it for other users unless they right-click → Open. Distribution via DMG would require a separate signing step.
- Adding resources (images, asset catalogs, localisation bundles) would require extending `build.sh` to copy them into `.app/Contents/Resources`. SPM's resource bundling (`Bundle.module`) does not produce a macOS app bundle layout.
- `Info.plist` is maintained manually at the repo root. Changes to bundle metadata (version, `LSUIElement`, ATS settings) require editing the plist directly rather than through Xcode's GUI.
- Debug builds via `swift build` (without `build.sh`) produce a bare executable that works but has no app bundle identity — it cannot display a menu bar icon correctly in all macOS versions. `build.sh` is needed for a proper install.
