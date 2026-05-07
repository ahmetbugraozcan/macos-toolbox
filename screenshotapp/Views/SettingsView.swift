import AppKit
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

    @AppStorage(ScreenshotShelfSettings.Keys.autoSaveCapturedScreenshots)
    private var autoSaveCapturedScreenshots = ScreenshotShelfSettings.defaultAutoSaveCapturedScreenshots

    @AppStorage(ScreenshotShelfSettings.Keys.saveDirectoryPath)
    private var saveDirectoryPath = ScreenshotShelfSettings.defaultSaveDirectoryPath

    @AppStorage(ScreenshotShelfSettings.Keys.exportFilenamePrefix)
    private var exportFilenamePrefix = ScreenshotShelfSettings.defaultExportFilenamePrefix

    @AppStorage(ScreenshotShelfSettings.Keys.exportFilenameVariants)
    private var exportFilenameVariants = ScreenshotShelfSettings.defaultExportFilenameVariants

    @AppStorage(ToolboxSettings.Keys.menuLayout)
    private var menuLayoutRaw = ToolboxSettings.defaultMenuLayout.rawValue

    @State private var selectedSection: SettingsSection? = .screenshots

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                Section("App") {
                    ForEach(SettingsSection.appSections) { section in
                        Label(section.title, systemImage: section.systemImage)
                            .tag(section)
                    }
                }

                Section("Features") {
                    ForEach(SettingsSection.featureSections) { section in
                        Label(section.title, systemImage: section.systemImage)
                            .tag(section)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 150, ideal: 170)
        } detail: {
            selectedPane
        }
        .frame(width: 720, height: 500)
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

    @ViewBuilder
    private var selectedPane: some View {
        switch selectedSection ?? .screenshots {
        case .menuBar:
            menuBarPane
        case .screenshots:
            screenshotsPane
        case .finderPath:
            finderPathPane
        case .shortcuts:
            shortcutsPane
        }
    }

    private var menuBarPane: some View {
        SettingsPage(title: "Menu Bar", systemImage: "menubar.rectangle") {
            MenuLayoutSection(selection: $menuLayoutRaw)
        }
    }

    private var screenshotsPane: some View {
        SettingsPage(title: "Screenshots", systemImage: "camera.viewfinder") {
            ToolCategorySection(
                title: "Tools",
                tools: [.captureSelectedArea, .captureOCR, .imageSearch]
            )

            Form {
                Section("Preview") {
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

                Section("Capture") {
                    Toggle("Show previews on focused display", isOn: $showPreviewsOnFocusedDisplay)

                    Toggle("Copy new screenshots to clipboard", isOn: $copyCapturedScreenshotToClipboard)
                }

                Section("Export") {
                    Toggle("Auto-save captured screenshots", isOn: $autoSaveCapturedScreenshots)

                    LabeledContent("Save to") {
                        HStack(spacing: 8) {
                            Text(saveDirectoryPath)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Button("Choose...") {
                                chooseSaveDirectory()
                            }
                        }
                    }

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

    private var finderPathPane: some View {
        SettingsPage(title: "Finder Path", systemImage: "folder") {
            ToolCategorySection(
                title: "Tool",
                tools: [.copyFinderPath]
            )
        }
    }

    private var shortcutsPane: some View {
        SettingsPage(title: "Shortcuts", systemImage: "keyboard") {
            Form {
                Section("Screenshots") {
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

    private func chooseSaveDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.directoryURL = URL(fileURLWithPath: saveDirectoryPath, isDirectory: true)
        panel.prompt = "Choose"

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        saveDirectoryPath = url.path
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable, Hashable {
    case menuBar
    case screenshots
    case finderPath
    case shortcuts

    var id: Self { self }

    static let appSections: [Self] = [.menuBar, .shortcuts]
    static let featureSections: [Self] = [.screenshots, .finderPath]

    var title: String {
        switch self {
        case .menuBar: "Menu Bar"
        case .screenshots: "Screenshots"
        case .finderPath: "Finder Path"
        case .shortcuts: "Shortcuts"
        }
    }

    var systemImage: String {
        switch self {
        case .menuBar: "menubar.rectangle"
        case .screenshots: "camera.viewfinder"
        case .finderPath: "folder"
        case .shortcuts: "keyboard"
        }
    }
}

private struct SettingsPane<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            content
                .formStyle(.grouped)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

private struct SettingsPage<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        SettingsPane {
            VStack(alignment: .leading, spacing: 18) {
                Label(title, systemImage: systemImage)
                    .font(.title2.weight(.semibold))
                    .padding(.horizontal, 4)

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct MenuLayoutSection: View {
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Layout")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 16) {
                    Text("Menu layout")
                        .font(.system(size: 13, weight: .medium))

                    Spacer()

                    Picker("Menu layout", selection: $selection) {
                        ForEach(ToolboxMenuLayout.allCases) { layout in
                            Text(layout.title).tag(layout.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity)

                Text(selectedLayout.description)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var selectedLayout: ToolboxMenuLayout {
        ToolboxMenuLayout(rawValue: selection) ?? ToolboxSettings.defaultMenuLayout
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
