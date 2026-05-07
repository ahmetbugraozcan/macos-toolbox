import Foundation
import Testing
@testable import screenshotapp

struct screenshotappTests {

    @Test func screenshotSettingsRegisterAutoSaveDefaults() throws {
        let suiteName = "ScreenshotShelfSettingsTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        ScreenshotShelfSettings.registerDefaults(in: defaults)
        let snapshot = ScreenshotShelfSettings.snapshot(from: defaults)

        #expect(snapshot.autoSaveCapturedScreenshots)
        #expect(snapshot.saveDirectoryPath == ScreenshotShelfSettings.defaultSaveDirectoryPath)

        defaults.removePersistentDomain(forName: suiteName)
    }

}
