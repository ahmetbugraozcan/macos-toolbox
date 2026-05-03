import SwiftUI

struct ScreenshotShelfView: View {
    @ObservedObject var store: ScreenshotShelfStore

    @AppStorage(ScreenshotShelfSettings.Keys.stackDirection)
    private var stackDirectionRaw = ScreenshotShelfSettings.defaultStackDirection.rawValue

    @AppStorage(ScreenshotShelfSettings.Keys.thumbnailSize)
    private var thumbnailSizeRaw = ScreenshotShelfSettings.defaultThumbnailSize.rawValue

    @AppStorage(ScreenshotShelfSettings.Keys.customThumbnailWidth)
    private var customThumbnailWidth = ScreenshotShelfSettings.defaultCustomThumbnailWidth

    var body: some View {
        ScrollView(scrollAxis, showsIndicators: false) {
            stackContent
                .padding(Self.outerPadding)
        }
    }

    static let outerPadding: CGFloat = 8
    static let cardPadding: CGFloat = 8
    static let thumbnailSpacing: CGFloat = 12

    private var stackDirection: StackDirection {
        StackDirection(rawValue: stackDirectionRaw) ?? ScreenshotShelfSettings.defaultStackDirection
    }

    private var thumbnailSize: CGSize {
        let size = ShelfThumbnailSize(rawValue: thumbnailSizeRaw) ?? ScreenshotShelfSettings.defaultThumbnailSize
        let customWidth = ScreenshotShelfSettings.clampedCustomThumbnailWidth(customThumbnailWidth)

        return size.size(customWidth: customWidth)
    }

    private var scrollAxis: Axis.Set {
        stackDirection == .horizontal ? .horizontal : .vertical
    }

    @ViewBuilder
    private var stackContent: some View {
        if stackDirection == .horizontal {
            HStack(spacing: Self.thumbnailSpacing) {
                thumbnails
            }
        } else {
            VStack(spacing: Self.thumbnailSpacing) {
                thumbnails
            }
        }
    }

    @ViewBuilder
    private var thumbnails: some View {
        ForEach(store.screenshots) { item in
            ScreenshotThumbnailView(
                item: item,
                thumbnailSize: thumbnailSize,
                closeAction: { store.remove(item) },
                copyAction: { store.copy(item) },
                copyTextAction: { store.copyRecognizedText(item) },
                pinAction: { store.togglePin(item) },
                openAction: { store.openInPreview(item) }
            )
        }
    }

    static func cardSize(for thumbnailSize: CGSize) -> CGSize {
        CGSize(
            width: thumbnailSize.width + cardPadding * 2,
            height: thumbnailSize.height + cardPadding * 2
        )
    }
}

private struct ScreenshotThumbnailView: View {
    let item: ScreenshotItem
    let thumbnailSize: CGSize
    let closeAction: () -> Void
    let copyAction: () -> Void
    let copyTextAction: () -> Void
    let pinAction: () -> Void
    let openAction: () -> Void

    var body: some View {
        ZStack {
            Button(action: openAction) {
                Image(nsImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.quaternary, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .help("Open in Preview")

            VStack {
                HStack {
                    ThumbnailControlButton(
                        systemName: item.isPinned ? "pin.fill" : "pin",
                        help: item.isPinned ? "Unpin" : "Pin",
                        action: pinAction
                    )

                    Spacer()

                    ThumbnailControlButton(
                        systemName: "xmark",
                        help: "Close",
                        action: closeAction
                    )
                }

                Spacer()

                HStack {
                    ThumbnailControlButton(
                        systemName: "pencil",
                        help: "Edit in Preview",
                        action: openAction
                    )

                    Spacer()

                    ThumbnailControlButton(
                        systemName: "doc.on.doc",
                        help: "Copy",
                        action: copyAction
                    )
                }
            }
            .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            .padding(5)
        }
        .padding(ScreenshotShelfView.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        .frame(
            width: ScreenshotShelfView.cardSize(for: thumbnailSize).width,
            height: ScreenshotShelfView.cardSize(for: thumbnailSize).height
        )
        .contextMenu {
            Button {
                copyAction()
            } label: {
                Label("Copy Image", systemImage: "doc.on.doc")
            }

            Button {
                copyTextAction()
            } label: {
                Label("Copy Text", systemImage: "text.viewfinder")
            }

            Button {
                openAction()
            } label: {
                Label("Edit in Preview", systemImage: "pencil")
            }

            Button {
                pinAction()
            } label: {
                Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash" : "pin")
            }

            Divider()

            Button(role: .destructive) {
                closeAction()
            } label: {
                Label("Close", systemImage: "xmark")
            }
        }
    }
}

private struct ThumbnailControlButton: View {
    let systemName: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(.black.opacity(0.58), in: Circle())
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
