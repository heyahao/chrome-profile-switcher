// Safari 无界面窗口启动器。版本由 VERSION 管理。
import AppKit
import ApplicationServices

private let safariBundleID = "com.apple.Safari"
private let rememberedWindowKey = "lastMinimizedWindow"

private func value<T>(_ element: AXUIElement, _ name: String, as type: T.Type) -> T? {
    var result: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &result) == .success else { return nil }
    return result as? T
}

private func windowState(_ window: AXUIElement) -> SafariWindowState {
    SafariWindowState(
        identifier: value(window, kAXIdentifierAttribute, as: String.self) ?? "",
        isMain: value(window, kAXMainAttribute, as: Bool.self) ?? false,
        isMinimized: value(window, kAXMinimizedAttribute, as: Bool.self) ?? false,
        isFullScreen: value(window, "AXFullScreen", as: Bool.self) ?? false,
        isStandard: value(window, kAXSubroleAttribute, as: String.self) == kAXStandardWindowSubrole
    )
}

private func openSafari() -> Int32 {
    // 由 LaunchServices 启动/重新打开 Safari，不发送任何网址或新窗口快捷键。
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: safariBundleID) else { return 3 }
    let config = NSWorkspace.OpenConfiguration()
    config.activates = true
    var result: Int32?
    NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
        result = error == nil ? 0 : 4
    }
    let deadline = Date().addingTimeInterval(10)
    while result == nil && Date() < deadline {
        RunLoop.current.run(until: Date().addingTimeInterval(0.01))
    }
    return result ?? 4
}

@main
struct SafariWindowLauncher {
    static func main() {
        let started = Date()
        let args = CommandLine.arguments
        let snapshotOnly = args.contains("--snapshot")
        if args.contains("--check-permission") {
            print(AXIsProcessTrusted() ? "trusted" : "permission-required")
            exit(AXIsProcessTrusted() ? 0 : 2)
        }

        // 在启动/激活 Safari 之前读取真实前台，避免误触发最小化。
        let wasFrontmost = NSWorkspace.shared.frontmostApplication?.bundleIdentifier == safariBundleID
        let trusted = AXIsProcessTrusted()
        guard trusted else {
            if !snapshotOnly {
                let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
                _ = AXIsProcessTrustedWithOptions([prompt: true] as CFDictionary)
            }
            print("permission-required: Safari Toggle needs Accessibility access")
            exit(2)
        }

        guard let safari = NSRunningApplication.runningApplications(withBundleIdentifier: safariBundleID).first else {
            if snapshotOnly { print("{\"running\":false,\"windows\":[]}"); exit(0) }
            exit(openSafari())
        }

        let app = AXUIElementCreateApplication(safari.processIdentifier)
        AXUIElementSetMessagingTimeout(app, 1)
        var raw: CFTypeRef?
        let readStatus = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &raw)
        let windows = raw as? [AXUIElement] ?? []
        let reliable = readStatus == .success && raw is [AXUIElement]
        let states = windows.map(windowState)

        if snapshotOnly {
            // 不输出页面标题、网址或内容；只暴露测试所需的窗口身份和状态。
            let payload: [String: Any] = [
                "running": true, "frontmost": wasFrontmost, "reliable": reliable,
                "windows": states.map { ["id": $0.identifier, "main": $0.isMain,
                    "minimized": $0.isMinimized, "fullScreen": $0.isFullScreen, "standard": $0.isStandard] }
            ]
            let data = try! JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
            print(String(decoding: data, as: UTF8.self)); exit(0)
        }

        let defaults = UserDefaults.standard
        let action = safariWindowAction(windows: states, wasFrontmost: wasFrontmost,
            windowListReliable: reliable, minimizedByLauncher: defaults.string(forKey: rememberedWindowKey))
        var outcome = ""
        switch action {
        case .minimize(let index):
            let window = windows[index]
            var settable = DarwinBoolean(false)
            guard AXUIElementIsAttributeSettable(window, kAXMinimizedAttribute as CFString, &settable) == .success,
                  settable.boolValue else { print("minimize-unavailable"); exit(5) }
            guard AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanTrue) == .success else {
                print("minimize-failed"); exit(5)
            }
            let id = states[index].identifier
            if !id.isEmpty { defaults.set(id, forKey: rememberedWindowKey) }
            outcome = "minimized"
        case .focus(let index):
            let window = windows[index]
            if states[index].isMinimized {
                guard AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanFalse) == .success else {
                    print("restore-failed"); exit(5)
                }
            }
            safari.activate(options: [.activateIgnoringOtherApps])
            _ = AXUIElementSetAttributeValue(window, kAXMainAttribute as CFString, kCFBooleanTrue)
            let raised = AXUIElementPerformAction(window, kAXRaiseAction as CFString)
            guard raised == .success else { print("raise-failed"); exit(5) }
            defaults.removeObject(forKey: rememberedWindowKey)
            outcome = "focused"
        case .activate:
            safari.activate(options: [.activateIgnoringOtherApps])
            outcome = "activated"
        case .reopen:
            defaults.removeObject(forKey: rememberedWindowKey)
            exit(openSafari())
        }
        print("\(outcome) \(Int(Date().timeIntervalSince(started) * 1000))ms")
    }
}
