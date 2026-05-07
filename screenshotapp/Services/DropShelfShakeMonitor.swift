import AppKit
import Foundation

@MainActor
final class DropShelfShakeMonitor {
    var onShake: () -> Void = {}

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var lastPoint: CGPoint?
    private var lastDirection: CGFloat = 0
    private var directionChanges: [TimeInterval] = []
    private var lastTriggerTimestamp: TimeInterval = 0
    private var sensitivity = DropShelfSettings.defaultShakeSensitivity

    func update(settings: DropShelfSettingsSnapshot) {
        sensitivity = settings.shakeSensitivity

        guard settings.openOnShake,
              PrivacyPermissionService.status(for: .accessibility).isGranted else {
            stop()
            resetGesture()
            return
        }

        startIfNeeded()
    }

    func stop() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }

    private func startIfNeeded() {
        if globalMonitor == nil {
            globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) { [weak self] event in
                Task { @MainActor in
                    self?.handle(event)
                }
            }
        }

        if localMonitor == nil {
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged]) { [weak self] event in
                Task { @MainActor in
                    self?.handle(event)
                }

                return event
            }
        }
    }

    private func handle(_ event: NSEvent) {
        let point = NSEvent.mouseLocation
        defer {
            lastPoint = point
        }

        guard let lastPoint else {
            return
        }

        let deltaX = point.x - lastPoint.x
        let minimumDelta = max(7, 20 - CGFloat(sensitivity))

        guard abs(deltaX) >= minimumDelta else {
            return
        }

        let direction: CGFloat = deltaX > 0 ? 1 : -1
        let timestamp = event.timestamp

        if lastDirection != 0, direction != lastDirection {
            directionChanges.append(timestamp)
            directionChanges = directionChanges.filter { timestamp - $0 <= 0.8 }

            if directionChanges.count >= requiredDirectionChanges,
               timestamp - lastTriggerTimestamp > 1.2 {
                lastTriggerTimestamp = timestamp
                resetGesture()
                onShake()
                return
            }
        }

        lastDirection = direction
    }

    private var requiredDirectionChanges: Int {
        let normalized = DropShelfSettings.clampedShakeSensitivity(sensitivity)
        return max(2, 7 - Int((Double(normalized) / 2.0).rounded(.down)))
    }

    private func resetGesture() {
        lastPoint = nil
        lastDirection = 0
        directionChanges.removeAll()
    }
}
