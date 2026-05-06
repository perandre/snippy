# Snippy User Manual

Snippy is a menu bar app for macOS that lets you store text snippets and images and paste them instantly from any app.

---

## Opening and closing Snippy

Press **`⌥⌘V`** (Option + Command + V) from anywhere on your Mac to toggle the Snippy panel open or closed. You can also click the Snippy icon in the menu bar.

When the panel opens, the search field is focused automatically and the previous search is cleared so you start fresh each time.

To close the panel without copying anything, press **`Esc`** or click anywhere outside it.

---

## The panel layout

| Area | Description |
|------|-------------|
| **Search bar** | At the top — filters snippets as you type |
| **Snippet list** | Scrollable list of your stored snippets, sorted by how often you use them (most-used first) |
| **Footer** | "New Snippet" button on the left; keyboard hint on the right |

---

## Searching

Start typing in the search bar to filter the list. Snippy searches both labels and values. Clear the search bar to see all snippets again.

---

## Copying a snippet

- **Keyboard:** Use **`↑`** and **`↓`** to highlight a snippet, then press **`↵ Enter`** to copy it to the clipboard.
- **Mouse:** Click directly on the snippet's text or image to copy it.

After copying, the row flashes green briefly to confirm. The panel stays open so you can copy more if needed.

Every copy increments the snippet's use count, which pushes it higher in the list over time.

---

## Adding snippets

### Paste from clipboard (`⌘V`)

Copy something to your clipboard (text or image) in any app, open Snippy, and press **`⌘V`**. Snippy saves whatever is on the clipboard as a new snippet immediately. If the exact text already exists in the list, it is not duplicated.

### Type a new snippet manually (`⌘N` or the + button)

Press **`⌘N`** or click **"New Snippet"** in the footer. An input field appears at the top of the list.

- **Plain value:** Type your snippet and press **`↵ Enter`**. Example: `me@example.com`
- **With a label:** Type `Label: value` — the part before the first `: ` (colon + space) becomes a searchable label shown in a different colour. Example: `Email: me@example.com`

Press **`Esc`** to cancel without saving.

### Smart label detection

The label parser is designed not to break on values that naturally contain colons:

| Input | Result |
|-------|--------|
| `Email: me@example.com` | Label: **Email**, value: `me@example.com` |
| `https://example.com` | No label — saved as-is (URL starts with `//`) |
| `10:30` | No label — no letters before the colon |
| `{"key": "val"}` | No label — starts with `{` |

---

## Editing a snippet

Hover over a snippet to reveal the **pencil** and **trash** buttons on the right side.

Click the **pencil** icon (or right-click and choose "Edit") to edit inline.

- **Text snippets:** The field pre-fills with `label: value` (or just the value if there is no label). Edit freely and press **`↵ Enter`** to save. The same label rules apply as when adding.
- **Image snippets:** Only the label can be edited. The image itself cannot be changed (delete and re-paste instead). Press **`↵ Enter`** to save.

Press **`Esc`** to cancel an edit without saving.

---

## Deleting a snippet

Hover over a snippet and click the **trash** icon, or right-click and choose "Delete". Deletion is immediate and cannot be undone.

---

## Images

Copy any image (screenshot, photo, graphic) to your clipboard, then press **`⌘V`** inside Snippy to save it. Images are shown as thumbnails in the list.

Clicking an image snippet copies the image back to your clipboard, ready to paste.

You can add a searchable label to an image by editing it (pencil icon).

---

## Keyboard reference

| Key | Action |
|-----|--------|
| `⌥⌘V` | Open / close Snippy |
| `↑` / `↓` | Move selection up / down |
| `↵ Enter` | Copy selected snippet |
| `⌘V` | Paste clipboard as new snippet |
| `⌘N` | Start adding a new snippet manually |
| `Esc` | Dismiss panel (or cancel add / edit) |

> **Quitting Snippy:** Right-click the menu bar icon and choose "Quit Snippy". The `⌘Q` shortcut is intentionally disabled in the snippet panel to prevent accidental exits while typing.

---

## Data and privacy

Snippy stores your snippets locally in `~/Library/Application Support/Snippy/` as a plain JSON file plus PNG image files. No data ever leaves your Mac — Snippy has zero network access.
