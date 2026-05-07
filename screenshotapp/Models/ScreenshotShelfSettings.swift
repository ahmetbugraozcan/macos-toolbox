import CoreGraphics
import Foundation

enum PreviewPosition: String, CaseIterable, Identifiable {
    case bottomLeft = "bottom-left"
    case bottomRight = "bottom-right"
    case topLeft = "top-left"
    case topRight = "top-right"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bottomLeft: AppLocalization.string("Bottom Left")
        case .bottomRight: AppLocalization.string("Bottom Right")
        case .topLeft: AppLocalization.string("Top Left")
        case .topRight: AppLocalization.string("Top Right")
        }
    }
}

enum StackDirection: String, CaseIterable, Identifiable {
    case horizontal
    case vertical

    var id: String { rawValue }

    var title: String {
        switch self {
        case .horizontal: AppLocalization.string("Horizontal")
        case .vertical: AppLocalization.string("Vertical")
        }
    }
}

enum ShelfThumbnailSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .small: AppLocalization.string("Small")
        case .medium: AppLocalization.string("Medium")
        case .large: AppLocalization.string("Large")
        case .custom: AppLocalization.string("Custom")
        }
    }

    func size(customWidth: Int) -> CGSize {
        switch self {
        case .small: Self.size(forWidth: 132)
        case .medium: Self.size(forWidth: 176)
        case .large: Self.size(forWidth: 240)
        case .custom: Self.size(forWidth: CGFloat(customWidth))
        }
    }

    static func size(forWidth width: CGFloat) -> CGSize {
        CGSize(width: width, height: (width * 0.7).rounded())
    }
}

struct ScreenshotShelfSettingsSnapshot {
    let previewPosition: PreviewPosition
    let stackDirection: StackDirection
    let maxStackCount: Int
    let previewDurationSeconds: Int
    let neverAutoHide: Bool
    let pinScreenshotsByDefault: Bool
    let showPreviewsOnFocusedDisplay: Bool
    let copyCapturedScreenshotToClipboard: Bool
    let thumbnailSize: ShelfThumbnailSize
    let customThumbnailWidth: Int
    let autoSaveCapturedScreenshots: Bool
    let saveDirectoryPath: String

    var thumbnailDimensions: CGSize {
        thumbnailSize.size(customWidth: customThumbnailWidth)
    }

    var saveDirectoryURL: URL {
        URL(fileURLWithPath: saveDirectoryPath, isDirectory: true)
    }
}

enum ScreenshotShelfSettings {
    enum Keys {
        static let previewPosition = "previewPosition"
        static let stackDirection = "stackDirection"
        static let maxStackCount = "maxStackCount"
        static let previewDurationSeconds = "previewDurationSeconds"
        static let neverAutoHide = "neverAutoHide"
        static let pinScreenshotsByDefault = "pinScreenshotsByDefault"
        static let showPreviewsOnFocusedDisplay = "showPreviewsOnFocusedDisplay"
        static let copyCapturedScreenshotToClipboard = "copyCapturedScreenshotToClipboard"
        static let thumbnailSize = "thumbnailSize"
        static let customThumbnailWidth = "customThumbnailWidth"
        static let autoSaveCapturedScreenshots = "autoSaveCapturedScreenshots"
        static let saveDirectoryPath = "saveDirectoryPath"
        static let exportFilenamePrefix = "exportFilenamePrefix"
        static let exportFilenameVariants = "exportFilenameVariants"
    }

    static let maxStackCountRange = 1...10
    static let previewDurationRange = 1...60
    static let customThumbnailWidthRange = 120...420

    static let defaultPreviewPosition = PreviewPosition.bottomRight
    static let defaultStackDirection = StackDirection.horizontal
    static let defaultMaxStackCount = 5
    static let defaultPreviewDurationSeconds = 8
    static let defaultNeverAutoHide = true
    static let defaultPinScreenshotsByDefault = false
    static let defaultShowPreviewsOnFocusedDisplay = true
    static let defaultCopyCapturedScreenshotToClipboard = false
    static let defaultThumbnailSize = ShelfThumbnailSize.medium
    static let defaultCustomThumbnailWidth = 220
    static let defaultAutoSaveCapturedScreenshots = true
    static let defaultSaveDirectoryPath = FileManager.default.urls(
        for: .desktopDirectory,
        in: .userDomainMask
    ).first?.path ?? NSHomeDirectory().appending("/Desktop")
    static let defaultExportFilenamePrefix = ScreenshotExportNaming.defaultPrefix
    static let defaultExportFilenameVariants = ScreenshotExportNaming.defaultVariants

    static func registerDefaults(in defaults: UserDefaults = .standard) {
        defaults.register(defaults: defaultValues)
    }

    static func resetToDefaults(in defaults: UserDefaults = .standard) {
        for (key, value) in defaultValues {
            defaults.set(value, forKey: key)
        }
    }

    private static var defaultValues: [String: Any] {
        [
            Keys.previewPosition: defaultPreviewPosition.rawValue,
            Keys.stackDirection: defaultStackDirection.rawValue,
            Keys.maxStackCount: defaultMaxStackCount,
            Keys.previewDurationSeconds: defaultPreviewDurationSeconds,
            Keys.neverAutoHide: defaultNeverAutoHide,
            Keys.pinScreenshotsByDefault: defaultPinScreenshotsByDefault,
            Keys.showPreviewsOnFocusedDisplay: defaultShowPreviewsOnFocusedDisplay,
            Keys.copyCapturedScreenshotToClipboard: defaultCopyCapturedScreenshotToClipboard,
            Keys.thumbnailSize: defaultThumbnailSize.rawValue,
            Keys.customThumbnailWidth: defaultCustomThumbnailWidth,
            Keys.autoSaveCapturedScreenshots: defaultAutoSaveCapturedScreenshots,
            Keys.saveDirectoryPath: defaultSaveDirectoryPath,
            Keys.exportFilenamePrefix: defaultExportFilenamePrefix,
            Keys.exportFilenameVariants: defaultExportFilenameVariants
        ]
    }

    static func snapshot(from defaults: UserDefaults = .standard) -> ScreenshotShelfSettingsSnapshot {
        let previewPositionRaw = defaults.string(forKey: Keys.previewPosition)
        let stackDirectionRaw = defaults.string(forKey: Keys.stackDirection)
        let thumbnailSizeRaw = defaults.string(forKey: Keys.thumbnailSize)

        return ScreenshotShelfSettingsSnapshot(
            previewPosition: PreviewPosition(rawValue: previewPositionRaw ?? "") ?? defaultPreviewPosition,
            stackDirection: StackDirection(rawValue: stackDirectionRaw ?? "") ?? defaultStackDirection,
            maxStackCount: clampedMaxStackCount(defaults.integer(forKey: Keys.maxStackCount)),
            previewDurationSeconds: clampedPreviewDuration(defaults.integer(forKey: Keys.previewDurationSeconds)),
            neverAutoHide: defaults.bool(forKey: Keys.neverAutoHide),
            pinScreenshotsByDefault: defaults.bool(forKey: Keys.pinScreenshotsByDefault),
            showPreviewsOnFocusedDisplay: defaults.bool(forKey: Keys.showPreviewsOnFocusedDisplay),
            copyCapturedScreenshotToClipboard: defaults.bool(forKey: Keys.copyCapturedScreenshotToClipboard),
            thumbnailSize: ShelfThumbnailSize(rawValue: thumbnailSizeRaw ?? "") ?? defaultThumbnailSize,
            customThumbnailWidth: clampedCustomThumbnailWidth(defaults.integer(forKey: Keys.customThumbnailWidth)),
            autoSaveCapturedScreenshots: defaults.bool(forKey: Keys.autoSaveCapturedScreenshots),
            saveDirectoryPath: saveDirectoryPath(from: defaults)
        )
    }

    static func clampedMaxStackCount(_ value: Int) -> Int {
        min(max(value, maxStackCountRange.lowerBound), maxStackCountRange.upperBound)
    }

    static func clampedPreviewDuration(_ value: Int) -> Int {
        min(max(value, previewDurationRange.lowerBound), previewDurationRange.upperBound)
    }

    static func clampedCustomThumbnailWidth(_ value: Int) -> Int {
        min(max(value, customThumbnailWidthRange.lowerBound), customThumbnailWidthRange.upperBound)
    }

    private static func saveDirectoryPath(from defaults: UserDefaults) -> String {
        let path = defaults.string(forKey: Keys.saveDirectoryPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return path.isEmpty ? defaultSaveDirectoryPath : path
    }
}
