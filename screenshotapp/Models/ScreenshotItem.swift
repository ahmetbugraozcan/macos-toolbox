import AppKit
import Foundation

struct ScreenshotItem: Identifiable, Equatable {
    let id = UUID()
    let image: NSImage
    let createdAt = Date()
    var isPinned: Bool

    static func == (lhs: ScreenshotItem, rhs: ScreenshotItem) -> Bool {
        lhs.id == rhs.id
    }
}
