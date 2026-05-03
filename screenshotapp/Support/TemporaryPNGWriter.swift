import AppKit

enum TemporaryPNGWriter {
    static func write(_ image: NSImage) throws -> URL {
        guard let pngData = image.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }

        let filename = "TinyShotShelf-\(UUID().uuidString).png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try pngData.write(to: url, options: .atomic)
        return url
    }
}

private extension NSImage {
    func pngData() -> Data? {
        guard
            let tiffData = tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }

        return bitmap.representation(using: .png, properties: [:])
    }
}
