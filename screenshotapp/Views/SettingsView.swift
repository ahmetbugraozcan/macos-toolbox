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
            toolsPane
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver")
                }

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

    private var toolsPane: some View {
        SettingsPane {
            VStack(alignment: .leading, spacing: 18) {
                ToolCategorySection(
                    title: "Screenshots",
                    tools: [.captureSelectedArea, .captureOCR]
                )

                ToolCategorySection(
                    title: "Files",
                    tools: [.copyFinderPath]
                )

                ToolCategorySection(
                    title: "Search",
                    tools: [.imageSearch]
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

private struct ToolCategorySection: View {
    let title: String
    let tools: [ToolboxToolID]

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(tools) { tool in
                    ToolSettingsRow(tool: tool)
                }
            }
        }
    }
}

private struct ToolSettingsRow: View {
    let tool: ToolboxToolID
    @AppStorage private var isEnabled: Bool
    @AppStorage private var showInMenu: Bool

    init(tool: ToolboxToolID) {
        self.tool = tool
        _isEnabled = AppStorage(wrappedValue: tool.defaultEnabled, tool.enabledKey)
        _showInMenu = AppStorage(wrappedValue: tool.defaultShowInMenu, tool.showInMenuKey)
    }

    private var enabledBinding: Binding<Bool> {
        Binding {
            isEnabled
        } set: { newValue in
            isEnabled = newValue

            if !newValue {
                showInMenu = false
            }
        }
    }

    private var showInMenuBinding: Binding<Bool> {
        Binding {
            isEnabled && showInMenu
        } set: { newValue in
            showInMenu = isEnabled && newValue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: tool.systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.accentColor : Color.secondary)
                    .frame(width: 34, height: 34)
                    .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(tool.title)
                        .font(.system(size: 14, weight: .semibold))

                    Text(tool.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Toggle("", isOn: enabledBinding)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            HStack(spacing: 12) {
                Text("Show in menu")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isEnabled ? .secondary : .tertiary)

                Spacer()

                Toggle("", isOn: showInMenuBinding)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            .padding(.leading, 46)
            .disabled(!isEnabled)
        }
        .padding(14)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
        .opacity(isEnabled ? 1 : 0.58)
        .animation(.snappy(duration: 0.16), value: isEnabled)
        .onChange(of: isEnabled) { _, newValue in
            if !newValue {
                showInMenu = false
            }
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
