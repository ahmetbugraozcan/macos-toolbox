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
    @Environment(\.openWindow) private var openWindow
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
                screenshotStore.copyAll()
            } label: {
                Label("Copy All", systemImage: "doc.on.doc")
            }
            .disabled(screenshotStore.screenshots.isEmpty)

            Button(role: .destructive) {
                screenshotStore.clearAll()
            } label: {
                Label("Clear All", systemImage: "trash")
            }
            .disabled(screenshotStore.screenshots.isEmpty)

            Divider()

            Button {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "image-search")
            } label: {
                Label("Search Images", systemImage: "magnifyingglass")
            }

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

        Window("Image Search", id: "image-search") {
            ImageTextSearchView()
        }
        .defaultSize(width: 720, height: 500)
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
