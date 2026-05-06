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
            if shouldShowScreenshotsMenu {
                Menu {
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

                    if shouldShowCaptureSelectedAreaInMenu || shouldShowCaptureOCRInMenu {
                        Divider()
                    }

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
                } label: {
                    Label("Screenshots", systemImage: "camera.viewfinder")
                }

                Divider()
            }

            if shouldShowCopyFinderPathInMenu {
                Button {
                    screenshotStore.copyFrontFinderPath()
                } label: {
                    Label(ToolboxToolID.copyFinderPath.title, systemImage: ToolboxToolID.copyFinderPath.systemImage)
                }

                Divider()
            }

            if shouldShowImageSearchInMenu {
                Button {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "image-search")
                } label: {
                    Label(ToolboxToolID.imageSearch.title, systemImage: ToolboxToolID.imageSearch.systemImage)
                }

                Divider()
            }

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

    private var shouldShowScreenshotsMenu: Bool {
        shouldShowCaptureSelectedAreaInMenu
            || shouldShowCaptureOCRInMenu
            || !screenshotStore.screenshots.isEmpty
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
