//
//  screenshotappApp.swift
//  screenshotapp
//
//  Created by Ahmet Buğra Özcan on 2.05.2026.
//

import AppKit
import SwiftUI

@main
struct screenshotappApp: App {
    @Environment(\.openSettings) private var openSettings
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var screenshotStore = ScreenshotShelfStore()

    init() {
        ScreenshotShelfSettings.registerDefaults()
    }

    var body: some Scene {
        MenuBarExtra("TinyShotShelf", systemImage: "camera.viewfinder") {
            Button {
                screenshotStore.captureSelectedArea()
            } label: {
                Label("Capture Selected Area", systemImage: "camera.viewfinder")
            }
            .disabled(screenshotStore.isCapturing)

            Button {
                screenshotStore.captureOCRTextFromSelectedArea()
            } label: {
                Label("Capture OCR", systemImage: "text.viewfinder")
            }
            .disabled(screenshotStore.isCapturing)

            Divider()

            Button {
                NSApp.activate(ignoringOtherApps: true)
                openSettings()
            } label: {
                Label("Settings", systemImage: "gearshape")
            }

            Divider()

            Button("Quit TinyShotShelf") {
                NSApp.terminate(nil)
            }
        }

        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
