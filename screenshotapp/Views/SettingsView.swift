import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @AppStorage(ScreenshotShelfSettings.Keys.previewPosition)
    private var previewPositionRaw = ScreenshotShelfSettings.defaultPreviewPosition.rawValue

    @AppStorage(ScreenshotShelfSettings.Keys.stackDirection)
    private var stackDirectionRaw = ScreenshotShelfSettings.defaultStackDirection.rawValue

    @AppStorage(ScreenshotShelfSettings.Keys.maxStackCount)
    private var maxStackCount = ScreenshotShelfSettings.defaultMaxStackCount

    @AppStorage(ScreenshotShelfSettings.Keys.previewDurationSeconds)
    private var previewDurationSeconds = ScreenshotShelfSettings.defaultPreviewDurationSeconds

    @AppStorage(ScreenshotShelfSettings.Keys.neverAutoHide)
    private var neverAutoHide = ScreenshotShelfSettings.defaultNeverAutoHide

    @AppStorage(ScreenshotShelfSettings.Keys.pinScreenshotsByDefault)
    private var pinScreenshotsByDefault = ScreenshotShelfSettings.defaultPinScreenshotsByDefault

    @AppStorage(ScreenshotShelfSettings.Keys.showPreviewsOnFocusedDisplay)
    private var showPreviewsOnFocusedDisplay = ScreenshotShelfSettings.defaultShowPreviewsOnFocusedDisplay

    @AppStorage(ScreenshotShelfSettings.Keys.copyCapturedScreenshotToClipboard)
    private var copyCapturedScreenshotToClipboard = ScreenshotShelfSettings.defaultCopyCapturedScreenshotToClipboard

    @AppStorage(ScreenshotShelfSettings.Keys.thumbnailSize)
    private var thumbnailSizeRaw = ScreenshotShelfSettings.defaultThumbnailSize.rawValue

    @AppStorage(ScreenshotShelfSettings.Keys.customThumbnailWidth)
    private var customThumbnailWidth = ScreenshotShelfSettings.defaultCustomThumbnailWidth

    @AppStorage(ScreenshotShelfSettings.Keys.exportFilenamePrefix)
    private var exportFilenamePrefix = ScreenshotShelfSettings.defaultExportFilenamePrefix

    @AppStorage(ScreenshotShelfSettings.Keys.exportFilenameVariants)
    private var exportFilenameVariants = ScreenshotShelfSettings.defaultExportFilenameVariants

    var body: some View {
        TabView {
            previewPane
                .tabItem {
                    Label("Preview", systemImage: "rectangle.on.rectangle")
                }

            behaviorPane
                .tabItem {
                    Label("Behavior", systemImage: "slider.horizontal.3")
                }

            capturePane
                .tabItem {
                    Label("Capture", systemImage: "camera.viewfinder")
                }

            exportPane
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.down")
                }

            hotkeyPane
                .tabItem {
                    Label("Hotkey", systemImage: "keyboard")
                }
        }
        .frame(width: 560, height: 420)
        .onAppear(perform: clampNumericSettings)
        .onChange(of: maxStackCount) { _, newValue in
            maxStackCount = ScreenshotShelfSettings.clampedMaxStackCount(newValue)
        }
        .onChange(of: previewDurationSeconds) { _, newValue in
            previewDurationSeconds = ScreenshotShelfSettings.clampedPreviewDuration(newValue)
        }
        .onChange(of: customThumbnailWidth) { _, newValue in
            customThumbnailWidth = ScreenshotShelfSettings.clampedCustomThumbnailWidth(newValue)
        }
    }

    private var previewPane: some View {
        SettingsPane {
            Form {
                Section("Placement") {
                    Picker("Position", selection: $previewPositionRaw) {
                        ForEach(PreviewPosition.allCases) { position in
                            Text(position.title).tag(position.rawValue)
                        }
                    }

                    Picker("Stack direction", selection: $stackDirectionRaw) {
                        ForEach(StackDirection.allCases) { direction in
                            Text(direction.title).tag(direction.rawValue)
                        }
                    }
                }

                Section("Thumbnail") {
                    Picker("Size", selection: $thumbnailSizeRaw) {
                        ForEach(ShelfThumbnailSize.allCases) { size in
                            Text(size.title).tag(size.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedThumbnailSize == .custom {
                        CustomThumbnailSizeControl(
                            width: $customThumbnailWidth,
                            height: customThumbnailHeight
                        )
                    }
                }
            }
        }
    }

    private var behaviorPane: some View {
        SettingsPane {
            Form {
                Section("Stack") {
                    Stepper(
                        "Max stack count: \(maxStackCount)",
                        value: $maxStackCount,
                        in: ScreenshotShelfSettings.maxStackCountRange
                    )

                    Toggle("Pin screenshots by default", isOn: $pinScreenshotsByDefault)
                }

                Section("Auto-hide") {
                    Stepper(
                        "Preview duration: \(previewDurationSeconds) sec",
                        value: $previewDurationSeconds,
                        in: ScreenshotShelfSettings.previewDurationRange
                    )
                    .disabled(neverAutoHide)

                    Toggle("Never auto-hide", isOn: $neverAutoHide)
                }
            }
        }
    }

    private var capturePane: some View {
        SettingsPane {
            Form {
                Section("Display") {
                    Toggle("Show previews on focused display", isOn: $showPreviewsOnFocusedDisplay)
                }

                Section("Clipboard") {
                    Toggle("Copy new screenshots to clipboard", isOn: $copyCapturedScreenshotToClipboard)
                }
            }
        }
    }

    private var exportPane: some View {
        SettingsPane {
            Form {
                Section("Naming") {
                    TextField("Prefix", text: $exportFilenamePrefix)
                        .textFieldStyle(.roundedBorder)

                    TextField("Variants", text: $exportFilenameVariants)
                        .textFieldStyle(.roundedBorder)
                }

                Section("Generated names") {
                    ForEach(exportOptions) { option in
                        LabeledContent(option.variant ?? "Default") {
                            Text(option.filename)
                                .monospaced()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var hotkeyPane: some View {
        SettingsPane {
            Form {
                Section("Capture") {
                    KeyboardShortcuts.Recorder(
                        "Selected area:",
                        name: .captureSelectedArea
                    )
                }
            }
        }
    }

    private var selectedThumbnailSize: ShelfThumbnailSize {
        ShelfThumbnailSize(rawValue: thumbnailSizeRaw) ?? ScreenshotShelfSettings.defaultThumbnailSize
    }

    private var customThumbnailHeight: Int {
        let width = ScreenshotShelfSettings.clampedCustomThumbnailWidth(customThumbnailWidth)
        return Int(ShelfThumbnailSize.size(forWidth: CGFloat(width)).height)
    }

    private var exportOptions: [ScreenshotExportOption] {
        ScreenshotExportNaming.options(
            prefix: exportFilenamePrefix,
            variants: exportFilenameVariants
        )
    }

    private func clampNumericSettings() {
        maxStackCount = ScreenshotShelfSettings.clampedMaxStackCount(maxStackCount)
        previewDurationSeconds = ScreenshotShelfSettings.clampedPreviewDuration(previewDurationSeconds)
        customThumbnailWidth = ScreenshotShelfSettings.clampedCustomThumbnailWidth(customThumbnailWidth)
    }
}

private struct SettingsPane<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            content
                .formStyle(.grouped)
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
        }
    }
}

private struct CustomThumbnailSizeControl: View {
    @Binding var width: Int
    let height: Int

    private var widthSliderValue: Binding<Double> {
        Binding {
            Double(width)
        } set: { newValue in
            width = ScreenshotShelfSettings.clampedCustomThumbnailWidth(Int(newValue.rounded()))
        }
    }

    var body: some View {
        Group {
            LabeledContent("Dimensions") {
                HStack(spacing: 8) {
                    TextField("", value: $width, format: .number)
                        .frame(width: 72)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)

                    Text("x \(height) px")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    Stepper(
                        "",
                        value: $width,
                        in: ScreenshotShelfSettings.customThumbnailWidthRange
                    )
                    .labelsHidden()
                }
            }

            LabeledContent("Width") {
                HStack(spacing: 8) {
                    Text("\(ScreenshotShelfSettings.customThumbnailWidthRange.lowerBound)")
                    Slider(
                        value: widthSliderValue,
                        in: Double(ScreenshotShelfSettings.customThumbnailWidthRange.lowerBound)...Double(ScreenshotShelfSettings.customThumbnailWidthRange.upperBound)
                    )
                    .frame(width: 190)
                    Text("\(ScreenshotShelfSettings.customThumbnailWidthRange.upperBound)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
        }
    }
}
