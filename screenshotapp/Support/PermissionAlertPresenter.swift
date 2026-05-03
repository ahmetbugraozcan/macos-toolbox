import AppKit

@MainActor
enum PermissionAlertPresenter {
    static func showScreenRecordingHelp(openSettings: () -> Void) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = """
        Enable TinyShotShelf in System Settings > Privacy & Security > Screen & System Audio Recording, then quit and reopen TinyShotShelf.
        """
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            openSettings()
        }
    }
}
