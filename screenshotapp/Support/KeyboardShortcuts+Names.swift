import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    nonisolated static let captureSelectedArea = Self(
        "captureSelectedArea",
        default: .init(.two, modifiers: [.command, .shift])
    )
}
