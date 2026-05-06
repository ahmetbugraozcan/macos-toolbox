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
    @AppStorage(ToolboxSettings.Keys.menuLayout)
    private var menuLayoutRaw = ToolboxSettings.defaultMenuLayout.rawValue
    @AppStorage(ToolboxSettings.Keys.captureSelectedAreaEnabled)
    private var captureSelectedAreaEnabled = ToolboxSettings.defaultCaptureSelectedAreaEnabled
    @AppStorage(ToolboxSettings.Keys.captureSelectedAreaShowInMenu)
    private var captureSelectedAreaShowInMenu = ToolboxSettings.defaultCaptureSelectedAreaShowInMenu
    @AppStorage(ToolboxSettings.Keys.captureOCREnabled)
    private var captureOCREnabled = ToolboxSettings.defaultCaptureOCREnabled
    @AppStorage(ToolboxSettings.Keys.captureOCRShowInMenu)
    private var captureOCRShowInMenu = ToolboxSettings.defaultCaptureOCRShowInMenu
    @AppStorage(ToolboxSettings.Keys.copyFinderPathEnabled)
    private var copyFinderPathEnabled = ToolboxSettings.defaultCopyFinderPathEnabled
    @AppStorage(ToolboxSettings.Keys.copyFinderPathShowInMenu)
    private var copyFinderPathShowInMenu = ToolboxSettings.defaultCopyFinderPathShowInMenu
    @AppStorage(ToolboxSettings.Keys.imageSearchEnabled)
    private var imageSearchEnabled = ToolboxSettings.defaultImageSearchEnabled
    @AppStorage(ToolboxSettings.Keys.imageSearchShowInMenu)
    private var imageSearchShowInMenu = ToolboxSettings.defaultImageSearchShowInMenu

    init() {
        ScreenshotShelfSettings.registerDefaults()
        ToolboxSettings.registerDefaults()
    }

    var body: some Scene {
        MenuBarExtra("TinyShotShelf", systemImage: "camera.viewfinder") {
            switch selectedMenuLayout {
            case .expanded:
                expandedMenuContent
            case .grouped:
                groupedMenuContent
            }

            appMenuFooter
        }

        Settings {
            SettingsView()
        }

        Window("Image Search", id: "image-search") {
            ImageTextSearchView()
        }
        .defaultSize(width: 720, height: 500)
    }

    @ViewBuilder
    private var expandedMenuContent: some View {
        if shouldShowScreenshotActionsInMenu {
            menuSectionHeader("Screenshots")
            screenshotToolButtons

            if hasVisibleScreenshotTools {
                Divider()
            }

            screenshotShelfButtons

            Divider()
        }

        if shouldShowCopyFinderPathInMenu {
            menuSectionHeader("Files")
            copyFinderPathButton
            Divider()
        }
    }

    @ViewBuilder
    private var groupedMenuContent: some View {
        if shouldShowScreenshotActionsInMenu {
            Menu {
                screenshotToolButtons

                if hasVisibleScreenshotTools {
                    Divider()
                }

                screenshotShelfButtons
            } label: {
                Label("Screenshots", systemImage: "camera.viewfinder")
            }

            Divider()
        }

        if shouldShowCopyFinderPathInMenu {
            copyFinderPathButton
            Divider()
        }
    }

    @ViewBuilder
    private var screenshotToolButtons: some View {
        if shouldShowCaptureSelectedAreaInMenu {
            Button {
                screenshotStore.captureSelectedArea()
            } label: {
                Label(
                    ToolboxToolID.captureSelectedArea.title,
                    systemImage: ToolboxToolID.captureSelectedArea.systemImage
                )
            }
            .disabled(screenshotStore.isCapturing)
        }

        if shouldShowCaptureOCRInMenu {
            Button {
                screenshotStore.captureOCRTextFromSelectedArea()
            } label: {
                Label(ToolboxToolID.captureOCR.title, systemImage: ToolboxToolID.captureOCR.systemImage)
            }
            .disabled(screenshotStore.isCapturing)
        }

        if shouldShowImageSearchInMenu {
            Button {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "image-search")
            } label: {
                Label(ToolboxToolID.imageSearch.title, systemImage: ToolboxToolID.imageSearch.systemImage)
            }
        }
    }

    @ViewBuilder
    private var screenshotShelfButtons: some View {
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
    }

    private var copyFinderPathButton: some View {
        Button {
            screenshotStore.copyFrontFinderPath()
        } label: {
            Label(ToolboxToolID.copyFinderPath.title, systemImage: ToolboxToolID.copyFinderPath.systemImage)
        }
    }

    @ViewBuilder
    private var appMenuFooter: some View {
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

    private var selectedMenuLayout: ToolboxMenuLayout {
        ToolboxMenuLayout(rawValue: menuLayoutRaw) ?? ToolboxSettings.defaultMenuLayout
    }

    private func menuSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .disabled(true)
    }

    private var shouldShowScreenshotActionsInMenu: Bool {
        hasVisibleScreenshotTools
            || !screenshotStore.screenshots.isEmpty
    }

    private var hasVisibleScreenshotTools: Bool {
        shouldShowCaptureSelectedAreaInMenu
            || shouldShowCaptureOCRInMenu
            || shouldShowImageSearchInMenu
    }

    private var shouldShowCaptureSelectedAreaInMenu: Bool {
        captureSelectedAreaEnabled && captureSelectedAreaShowInMenu
    }

    private var shouldShowCaptureOCRInMenu: Bool {
        captureOCREnabled && captureOCRShowInMenu
    }

    private var shouldShowCopyFinderPathInMenu: Bool {
        copyFinderPathEnabled && copyFinderPathShowInMenu
    }

    private var shouldShowImageSearchInMenu: Bool {
        imageSearchEnabled && imageSearchShowInMenu
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
