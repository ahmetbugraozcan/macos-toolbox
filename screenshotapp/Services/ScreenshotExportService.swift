import AppKit
import UniformTypeIdentifiers

@MainActor
enum ScreenshotExportService {
    static func save(
        _ image: NSImage,
        suggestedFilename: String
    ) throws -> URL? {
        guard let pngData = image.tinyShotShelfPNGData else {
            throw CocoaError(.fileWriteUnknown)
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = suggestedFilename

        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }

        try pngData.write(to: url, options: .atomic)
        return url
    }
}
