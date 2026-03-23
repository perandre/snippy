import SwiftUI
import AppKit

struct SnippetRow: View {
    let snippet: Snippet
    let isSelected: Bool
    let isCopied: Bool
    let isHovered: Bool
    let image: NSImage?
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Content area — copies snippet
            VStack(alignment: .leading, spacing: 2) {
                if !snippet.title.isEmpty {
                    Text(snippet.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if snippet.isImage, let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Text(snippet.value)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { onCopy() }

            ZStack {
                if isCopied {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 14))
                } else {
                    HStack(spacing: 2) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11))
                                .frame(width: 24, height: 24)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)

                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                                .frame(width: 24, height: 24)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                    .opacity(isHovered ? 1 : 0)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, snippet.isImage ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
        .animation(.easeOut(duration: 0.15), value: isCopied)
        .animation(.easeOut(duration: 0.1), value: isHovered)
        .contextMenu {
            Button("Copy") { onCopy() }
            Button("Edit") { onEdit() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }

    private var backgroundColor: Color {
        if isCopied {
            return .green.opacity(0.15)
        } else if isSelected {
            return .accentColor.opacity(0.15)
        } else if isHovered {
            return .primary.opacity(0.05)
        }
        return .clear
    }
}
