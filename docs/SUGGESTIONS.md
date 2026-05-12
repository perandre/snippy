# Snippy — Suggestions

Improvement ideas surfaced during code review. Capped at 3 per night; ordered by estimated user impact.

---

## 1. Categories / folders for snippet organisation

**Why:** As a user's snippet library grows beyond ~30 entries, use-count sorting alone is not enough to stay organised. A user storing both work templates, personal info, and code snippets has no way to separate them today. Grouping snippets into named categories (or at minimum tagging them with a colour) would let users find the right snippet faster and keep the list manageable. The `category` key is already present in `Snippet.CodingKeys` but unused, signalling this was already anticipated.

**Effort:** M

**Files involved:**
- `Sources/Snippet.swift` — add `category: String?` property
- `Sources/SnippetStore.swift` — update `filtered(by:)` to filter by category; add category CRUD
- `Sources/ContentView.swift` — add a category picker or sidebar strip above the list
- `Sources/AddSnippetRow.swift`, `Sources/EditSnippetRow.swift` — expose category selection in add/edit rows

---

## 2. Confirm before delete (or provide undo)

**Why:** Deletion is currently instant and irreversible — there is no confirmation dialog and no undo. A snippet deleted by accident (e.g. clicking the trash icon instead of the pencil) is gone permanently, along with its image file on disk. For text snippets this is annoying; for images it is unrecoverable. A single-step undo (⌘Z) or a brief "Deleted — Undo" toast would eliminate this risk with minimal friction.

**Effort:** S

**Files involved:**
- `Sources/SnippetRow.swift` — add a confirmation step or emit a delete-with-undo event
- `Sources/ContentView.swift` — manage a short-lived undo stack (a single `deletedSnippet` state is enough)
- `Sources/SnippetStore.swift` — add a `restore(_:)` method that re-inserts a deleted snippet and its image file

---

## 4. Export and import snippets

**Why:** There is currently no way to back up or migrate a snippet library other than manually copying `snippets.json` from `~/Library/Application Support/Snippy/`. Users setting up a new Mac, restoring from backup, or sharing a curated snippet set with a colleague have no in-app mechanism. A simple "Export…" menu item that writes a JSON or plain-text file, paired with an "Import…" action that merges (deduplicating by value), would cover the most common cases with minimal implementation effort.

**Effort:** S

**Files involved:**
- `Sources/SnippetStore.swift` — add `export() -> Data` and `importFrom(_ data: Data)` methods
- `Sources/SnippyApp.swift` — add "Export Snippets…" and "Import Snippets…" to the right-click context menu using `NSSavePanel` / `NSOpenPanel`

---

## 5. Customisable global hotkey

**Why:** `⌥⌘V` is Snippy's fixed shortcut and cannot be changed. Power users who already have another tool on that combination, or who prefer a different chord, must live with the conflict. Recording a user-chosen shortcut and persisting it to `UserDefaults` would make the app far more composable in custom keyboard setups. The Carbon `RegisterEventHotKey` call is already isolated in `AppDelegate.registerGlobalHotKey()`, so swapping in a stored combination is a contained change.

**Effort:** M

**Files involved:**
- `Sources/SnippyApp.swift` — add a preferences window or popover with a shortcut recorder; unregister the old hotkey and register the new one on change
- `Sources/SnippetStore.swift` (or a new `Preferences.swift`) — persist the chosen key code and modifier flags to `UserDefaults`

---

## 6. Pin / favourite snippets

**Why:** Use-count sorting is good for frequently copied snippets, but a freshly added snippet always starts at zero and sinks to the bottom of the list — even if it is something the user knows they will need constantly (e.g., a frequently used template they just created). A simple "pin" toggle that locks a snippet to the top of the list regardless of use count would give users explicit control without replacing the automatic ranking for everything else.

**Effort:** S

**Files involved:**
- `Sources/Snippet.swift` — add `isPinned: Bool` property (with `CodingKeys` extension for backwards-compatible decode)
- `Sources/SnippetStore.swift` — update `filtered(by:)` to sort pinned snippets before use-count sorted ones
- `Sources/SnippetRow.swift` — add a pin button in the hover actions alongside the existing pencil and trash icons

---

## 3. iCloud sync via NSUbiquitousKeyValueStore or CloudKit

**Why:** Users who work across multiple Macs (e.g. a laptop and a desktop) currently have no way to share their snippet library. Manually copying `snippets.json` is the only option. `NSUbiquitousKeyValueStore` supports up to 1 MB of data with zero server infrastructure and would cover most text-only libraries. For image-heavy libraries, a lightweight CloudKit private database would be needed. Offering even the simpler key-value option would be a meaningful quality-of-life improvement for multi-device users.

**Effort:** L

**Files involved:**
- `Sources/SnippetStore.swift` — add a sync layer that mirrors saves to/from iCloud storage; handle merge conflicts (last-write-wins by `lastUsedAt` is probably sufficient)
- `Info.plist` — add `NSUbiquitousContainers` or CloudKit entitlement keys
- `Package.swift` / `build.sh` — may require a signed app identity and the iCloud capability in Xcode

---

## 7. Last-used date and usage heat indicator on each row

**Why:** Every snippet already tracks `lastUsedAt` and `useCount`, but neither field is visible in the UI. A user who wants to audit their snippet library — to prune stale entries or understand which snippets they actually rely on — has no way to see this data. Showing a subtle "last used X days ago" tooltip on hover, or a small colour-coded heat bar (cold blue → warm orange based on recency), would surface the already-collected data at zero storage cost and help users decide what to keep, edit, or delete.

**Effort:** S

**Files involved:**
- `Sources/SnippetRow.swift` — add a tooltip modifier on the content area showing `lastUsedAt` formatted as a relative date; optionally add a 3–4 px accent bar on the left edge coloured by recency
- `Sources/Snippet.swift` — no schema changes needed; `lastUsedAt` and `useCount` are already persisted

---

## 8. Quick-cycle mode: copy the next snippet without opening the panel

**Why:** A user who repeatedly pastes the same two or three snippets in sequence (e.g., toggling between a work email address and a personal one) must open the Snippy panel, navigate, copy, dismiss, paste, and repeat. A secondary hotkey (e.g., `⌥⌘→`) that copies the next snippet in the sorted list without opening the panel would let power users cycle through their top snippets in a single keystroke. The snippet index could wrap around so the shortcut always works.

**Effort:** M

**Files involved:**
- `Sources/SnippyApp.swift` — register a second `EventHotKeyID` for the cycle-forward shortcut; call a new `copyNextSnippet()` action on `AppDelegate`
- `Sources/SnippetStore.swift` — add a `cycleIndex: Int` state variable that advances on each call to `copyNextSnippet()` and resets when the panel is opened normally
- `Sources/SnippyApp.swift` — post a brief `NSUserNotification`-style banner (or use `NSAlert` in sheet mode) so the user sees what was just copied without having to open the panel

---

## 9. Configurable panel position (remember last position or snap to screen edge)

**Why:** Snippy always opens centred horizontally near the top of the screen. Users who work with their most-used app in the top-left corner (e.g., a code editor with narrow sidebar) find the panel overlaps their cursor position. Letting users drag the panel to a preferred location and persisting that position to `UserDefaults` would remove the friction of repositioning on every invoke. A secondary option — "snap to status bar icon" — would make the panel behave like a standard menu bar popover for users who prefer that style.

**Effort:** S

**Files involved:**
- `Sources/SnippyApp.swift` — in `hidePanel()`, save `panel.frame.origin` to `UserDefaults`; in `showPanel()`, read the saved origin and skip the auto-centre calculation if one is present
- `Sources/SnippyApp.swift` — add a "Reset panel position" item to the right-click context menu so users can recover if they drag the panel off-screen

---

## 10. Auto-paste mode: copy + paste in one keystroke

**Why:** After selecting a snippet with Return (or a click), the text lands in the clipboard but the user still has to switch back to the target app and press ⌘V. For the common "pick snippet → paste immediately" workflow this is an unnecessary extra step. A modifier variant — e.g., holding ⌥ while pressing Return, or a dedicated ⌥Return binding — could copy the snippet, dismiss the panel, re-activate the previously focused app, and synthesise a ⌘V keystroke via `CGEvent`, completing the paste in one action. This would make Snippy feel as fast as a true text-expander for the most common use case.

**Effort:** M

**Files involved:**
- `Sources/ContentView.swift` — detect the ⌥Return chord in the key monitor; extract a `copyAndPaste(_:)` variant of the existing `copySnippet()` that additionally calls the paste helper
- `Sources/SnippyApp.swift` — add a `pasteToFrontmostApp()` helper that records the previously active app before `showPanel()` (store in `AppDelegate`), then re-activates it and posts a `CGEvent` ⌘V key pair after a short delay

---

## 11. Drag-to-reorder snippets in the list

**Why:** `SnippetStore` already implements `move(fromOffsets:toOffset:)` — the full reorder logic is in place — but no drag-and-drop UI is wired to it. When a user wants to manually curate their top snippets (e.g., keep a rarely used but important entry visible), the only lever today is indirect: copying a snippet increments its `useCount` and eventually floats it up. Exposing `.onMove` on the `LazyVStack` (or switching to a `List` for drag support) would let users directly control the order with zero extra storage cost.

**Effort:** S

**Files involved:**
- `Sources/ContentView.swift` — replace `LazyVStack` + `ForEach` with a `List` that has `.onMove { store.move(from:to:) }`, or add a drag handle + `onDrag`/`onDrop` pair to `SnippetRow` while keeping `LazyVStack`
- `Sources/SnippetStore.swift` — `move(fromOffsets:toOffset:)` already exists; ensure `filtered(by:)` preserves insertion-order when a manual order has been set (may need a separate `pinnedOrder: [UUID]` array when query is empty)

---

## 12. Clipboard-history auto-capture

**Why:** Snippy currently only adds clipboard content when the user explicitly presses ⌘V inside the panel. Users who copy things throughout the day and later wish they had saved them get no benefit. Polling `NSPasteboard.changeCount` on a short timer (e.g., every 2 seconds while the app is running) and silently appending new unique text entries to the snippet list would turn Snippy into a passive clipboard history without any extra user action. A configurable cap (e.g., keep last 50 auto-captured entries) and a visual distinction (e.g., a clock badge on auto-captured rows) would keep the list from growing unbounded.

**Effort:** M

**Files involved:**
- `Sources/SnippetStore.swift` — add an `autoCapture(from pasteboard: NSPasteboard)` method that checks `changeCount`, deduplicates by value, and inserts new entries tagged with a `source: .autoCapture` marker
- `Sources/SnippyApp.swift` — install a `Timer.scheduledTimer` in `applicationDidFinishLaunching` that calls `store.autoCapture(from: .general)` periodically; expose a `UserDefaults`-backed toggle so users can disable auto-capture
- `Sources/Snippet.swift` — add an optional `source: SnippetSource` enum (`manual` / `autoCapture`) used to style the row badge and enforce the cap
- `Sources/SnippetRow.swift` — show a small clock icon on auto-captured rows so users can distinguish them at a glance

---

## 13. Surface save errors instead of swallowing them silently

**Rationale:** `SnippetStore.save()` catches all errors with an empty `catch {}` block, meaning a disk-full condition, a permissions error on `snippets.json`, or an encoding failure will cause data loss with no feedback to the user. Because Snippy has no test target either, this path is never exercised. The fix is two-pronged: log the error at minimum, and post a brief `NSUserNotification`-style alert (or update a `@Published var lastSaveError: Error?` that `ContentView` watches) so users are not left wondering why new snippets disappear after a restart.

**Effort:** S

**Involved files:**
- `Sources/SnippetStore.swift` — replace the empty `catch {}` in `save()` with a `catch { self.lastSaveError = error }` and publish the error state
- `Sources/ContentView.swift` — observe `store.lastSaveError` and display a transient banner or sheet when it is non-nil

---

## 14. Orphaned image files are never cleaned up

**Rationale:** Image snippets write PNG files to `~/Library/Application Support/Snippy/images/` using `UUID().uuidString` filenames. The `delete(_:)` method removes the matching file when a snippet is deleted normally, but there is no defensive sweep: if the app crashes between writing the PNG and saving `snippets.json`, or if the JSON is manually edited, PNG files accumulate with no reference pointing to them. Over time a heavy image user could accumulate hundreds of MB of orphaned files. A startup reconciliation pass — comparing the `images/` directory to `snippet.imageFileName` values and deleting unmatched PNGs — would keep disk usage honest.

**Effort:** S

**Involved files:**
- `Sources/SnippetStore.swift` — add a `pruneOrphanedImages()` method called from `load()` after decoding; iterate `imagesDir` contents and `removeItem` any filename not referenced by a current snippet's `imageFileName`

---

## 15. Search field does not reliably regain focus when the panel reappears

**Rationale:** When Snippy's panel is hidden and re-shown, `ContentView` resets its state via the `snippyDidShow` notification, but `FocusState` (the standard SwiftUI mechanism used in `AddSnippetRow` and `EditSnippetRow`) does not work reliably in `NSPanel` floating windows — the same limitation that already forced all keyboard handling onto `NSEvent` local monitors. As a result, the search `TextField` may not be focused on re-open, so typing immediately after invoking the hotkey produces no output in the search bar. An explicit `NSApp.keyWindow?.makeFirstResponder(hostingView)` call or a targeted `NSTextField.becomeFirstResponder()` triggered by `snippyDidShow` would fix this consistently.

**Effort:** S

**Involved files:**
- `Sources/SnippyApp.swift` — after posting `snippyDidShow`, call `panel.makeFirstResponder(panel.contentView)` (or the specific hosting view) to push focus into the SwiftUI tree
- `Sources/ContentView.swift` — if a programmatic approach is insufficient, install a one-shot `NSEvent` monitor on `snippyDidShow` that synthesises a Tab key event to cycle focus into the search field

---

## 16. VoiceOver and assistive-technology support

**Why:** Snippy's entire keyboard interface is built on `NSEvent.addLocalMonitorForEvents`, which intercepts raw key events before they reach the accessibility layer. VoiceOver users cannot navigate the snippet list, hear snippet labels, or trigger copy/edit/delete actions — the app is effectively invisible to assistive technology. Adding `.accessibilityLabel`, `.accessibilityHint`, and `.accessibilityAction` modifiers to `SnippetRow`, the search bar, and the footer buttons would expose the full UI to VoiceOver. The `ContentView` key monitor should also pass events through when VoiceOver is active (`NSWorkspace.shared.isVoiceOverEnabled`) so VO's own navigation commands are not swallowed.

**Effort:** M

**Files involved:**
- `Sources/SnippetRow.swift` — add `.accessibilityLabel()` combining the title and a truncated value; add `.accessibilityAction(named: "Copy")`, `"Edit"`, `"Delete"` so VO users can invoke actions without hover buttons
- `Sources/ContentView.swift` — in `installKeyMonitor()`, check `NSWorkspace.shared.isVoiceOverEnabled` and return `event` (pass-through) for arrow/Return keys when VO is on, letting VO handle navigation natively
- `Sources/AddSnippetRow.swift`, `Sources/EditSnippetRow.swift` — add `.accessibilityLabel` on the input field describing its purpose

---

## 17. Snippet templates with fill-in placeholders

**Why:** Users who store repeated patterns — email replies, code boilerplate, bug-report outlines — must copy the snippet and then manually find-and-replace variable parts every time. Supporting a lightweight placeholder syntax (e.g. `{{name}}`, `{{date}}`) that, on copy, presents a small prompt for each placeholder before placing the filled-in result on the clipboard would turn Snippy from a static clipboard into a lightweight text-expander. The prompt could reuse the existing `NSPanel` infrastructure: show an inline row per placeholder, let the user tab through and press Return to confirm.

**Effort:** M

**Files involved:**
- `Sources/Snippet.swift` — add a computed `placeholders: [String]` that scans `value` for `{{…}}` tokens
- `Sources/ContentView.swift` — when `copySnippet()` detects placeholders, show a fill-in overlay instead of copying immediately; on confirm, substitute values and copy the expanded string
- `Sources/SnippetRow.swift` — show a small template badge (e.g. `⟨⟩` icon) on rows whose value contains placeholders, so users can distinguish static snippets from templates at a glance

---

## 18. Sensitive-value masking for passwords and tokens

**Why:** Users who store API keys, one-time passwords, or login credentials as snippets have those values displayed in plaintext in the snippet list — visible to anyone glancing at the screen. A per-snippet "sensitive" toggle that replaces the displayed value with `••••••••` until the user hovers or clicks would add a basic privacy layer without changing how copy works. The flag would persist in `snippets.json` and survive restarts, giving users a low-effort way to keep credentials out of casual sight while still benefiting from Snippy's quick-copy workflow.

**Effort:** S

**Files involved:**
- `Sources/Snippet.swift` — add `isSensitive: Bool` property (default `false`) with backwards-compatible decoding
- `Sources/SnippetRow.swift` — when `snippet.isSensitive && !isHovered`, display `String(repeating: "•", count: 8)` instead of `snippet.value`
- `Sources/EditSnippetRow.swift` — add a toggle or context-menu item to flip `isSensitive`
- `Sources/SnippetStore.swift` — encode/decode the new field
