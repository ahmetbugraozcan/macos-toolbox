import Foundation

enum ToolboxToolID: String, CaseIterable, Identifiable {
    case captureSelectedArea
    case captureOCR
    case copyFinderPath
    case imageSearch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .captureSelectedArea: "Capture Selected Area"
        case .captureOCR: "Capture OCR"
        case .copyFinderPath: "Copy Finder Path"
        case .imageSearch: "Search Images"
        }
    }

    var subtitle: String {
        switch self {
        case .captureSelectedArea: "Capture a selected screen region into the floating shelf."
        case .captureOCR: "Capture a selected region and copy recognized text."
        case .copyFinderPath: "Copy the front Finder window path to the clipboard."
        case .imageSearch: "Search local images by filename and recognized text."
        }
    }

    var systemImage: String {
        switch self {
        case .captureSelectedArea: "camera.viewfinder"
        case .captureOCR: "text.viewfinder"
        case .copyFinderPath: "folder"
        case .imageSearch: "magnifyingglass"
        }
    }

    var categoryTitle: String {
        switch self {
        case .captureSelectedArea, .captureOCR: "Screenshots"
        case .copyFinderPath: "Files"
        case .imageSearch: "Search"
        }
    }

    var enabledKey: String {
        switch self {
        case .captureSelectedArea: ToolboxSettings.Keys.captureSelectedAreaEnabled
        case .captureOCR: ToolboxSettings.Keys.captureOCREnabled
        case .copyFinderPath: ToolboxSettings.Keys.copyFinderPathEnabled
        case .imageSearch: ToolboxSettings.Keys.imageSearchEnabled
        }
    }

    var showInMenuKey: String {
        switch self {
        case .captureSelectedArea: ToolboxSettings.Keys.captureSelectedAreaShowInMenu
        case .captureOCR: ToolboxSettings.Keys.captureOCRShowInMenu
        case .copyFinderPath: ToolboxSettings.Keys.copyFinderPathShowInMenu
        case .imageSearch: ToolboxSettings.Keys.imageSearchShowInMenu
        }
    }

    var defaultEnabled: Bool {
        switch self {
        case .captureSelectedArea: ToolboxSettings.defaultCaptureSelectedAreaEnabled
        case .captureOCR: ToolboxSettings.defaultCaptureOCREnabled
        case .copyFinderPath: ToolboxSettings.defaultCopyFinderPathEnabled
        case .imageSearch: ToolboxSettings.defaultImageSearchEnabled
        }
    }

    var defaultShowInMenu: Bool {
        switch self {
        case .captureSelectedArea: ToolboxSettings.defaultCaptureSelectedAreaShowInMenu
        case .captureOCR: ToolboxSettings.defaultCaptureOCRShowInMenu
        case .copyFinderPath: ToolboxSettings.defaultCopyFinderPathShowInMenu
        case .imageSearch: ToolboxSettings.defaultImageSearchShowInMenu
        }
    }
}

enum ToolboxSettings {
    enum Keys {
        static let captureSelectedAreaEnabled = "tool.captureSelectedArea.enabled"
        static let captureSelectedAreaShowInMenu = "tool.captureSelectedArea.showInMenu"
        static let captureOCREnabled = "tool.captureOCR.enabled"
        static let captureOCRShowInMenu = "tool.captureOCR.showInMenu"
        static let copyFinderPathEnabled = "tool.copyFinderPath.enabled"
        static let copyFinderPathShowInMenu = "tool.copyFinderPath.showInMenu"
        static let imageSearchEnabled = "tool.imageSearch.enabled"
        static let imageSearchShowInMenu = "tool.imageSearch.showInMenu"
    }

    static let defaultCaptureSelectedAreaEnabled = true
    static let defaultCaptureSelectedAreaShowInMenu = true
    static let defaultCaptureOCREnabled = true
    static let defaultCaptureOCRShowInMenu = true
    static let defaultCopyFinderPathEnabled = true
    static let defaultCopyFinderPathShowInMenu = true
    static let defaultImageSearchEnabled = true
    static let defaultImageSearchShowInMenu = true

    static func registerDefaults(in defaults: UserDefaults = .standard) {
        defaults.register(defaults: [
            Keys.captureSelectedAreaEnabled: defaultCaptureSelectedAreaEnabled,
            Keys.captureSelectedAreaShowInMenu: defaultCaptureSelectedAreaShowInMenu,
            Keys.captureOCREnabled: defaultCaptureOCREnabled,
            Keys.captureOCRShowInMenu: defaultCaptureOCRShowInMenu,
            Keys.copyFinderPathEnabled: defaultCopyFinderPathEnabled,
            Keys.copyFinderPathShowInMenu: defaultCopyFinderPathShowInMenu,
            Keys.imageSearchEnabled: defaultImageSearchEnabled,
            Keys.imageSearchShowInMenu: defaultImageSearchShowInMenu
        ])
    }

    static func isEnabled(_ tool: ToolboxToolID, defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: tool.enabledKey)
    }
}
