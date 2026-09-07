import AppKit
import ApplicationServices

// AXWindows alone may be empty on another Space. Route through the named menu item.
func routeScript(tag: String, wasFrontmost: Bool) -> String {
    let literal = appleScriptString(tag)
    return """
    tell application "System Events"
        tell process "Google Chrome"
            set targetMenu to missing value
            repeat with candidate in menu bar items of menu bar 1
                if name of candidate is in {"窗口", "Window"} then
                    set targetMenu to menu 1 of candidate
                    exit repeat
                end if
            end repeat
            if targetMenu is missing value then return "MENU_UNAVAILABLE"
            set matches to every menu item of targetMenu whose name is \(literal)
            if (count of matches) is 0 then return "NOT_FOUND"
            if (count of matches) is not 1 then return "AMBIGUOUS"
            if \(wasFrontmost ? "true" : "false") then
                repeat with w in windows
                    set mainWindow to false
                    set fullScreen to true
                    try
                        set mainWindow to value of attribute "AXMain" of w
                        set fullScreen to value of attribute "AXFullScreen" of w
                    end try
                    if mainWindow and (name of w as text) starts with (\(literal) & " - ") then
                        if not fullScreen then
                            set value of attribute "AXMinimized" of w to true
                            return "MINIMIZED"
                        end if
                    end if
                end repeat
            end if
            perform action "AXPress" of item 1 of matches
            return "RAISED"
        end tell
    end tell
    """
}

func launchProfile(_ directory: String) -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = ["-n", "-a", "Google Chrome", "--args", "--profile-directory=\(directory)"]
    do { try process.run(); process.waitUntilExit(); return process.terminationStatus }
    catch { showMessage("无法启动 Chrome", "请先安装 Google Chrome。"); return 4 }
}

@main
struct ChromeProfileLauncher {
    static func main() {
        let args = CommandLine.arguments
        if args.contains("--check-script") {
            for tag in ["WorkWindow", "PersonalWindow", "工作 \\\"窗口"] {
                for front in [true, false] {
                    var error: NSDictionary?
                    guard NSAppleScript(source: routeScript(tag: tag, wasFrontmost: front))?.compileAndReturnError(&error) == true else {
                        print("script compilation failed"); exit(3)
                    }
                }
            }
            print("PASS AppleScript syntax for foreground/background and escaped names"); exit(0)
        }
        if args.contains("--check-permission") {
            print(AXIsProcessTrusted() ? "trusted" : "permission-required")
            exit(AXIsProcessTrusted() ? 0 : 2)
        }
        if let index = args.firstIndex(of: "--validate-config") {
            guard args.indices.contains(index + 1) else { exit(3) }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: args[index + 1]))
                let config = try JSONDecoder().decode(LauncherConfiguration.self, from: data)
                try config.validate(); print("valid"); exit(0)
            } catch { print("invalid configuration"); exit(3) }
        }
        if args.contains("--configure") || NSEvent.modifierFlags.contains(.shift)
            || !FileManager.default.fileExists(atPath: configurationURL().path) {
            exit(configureLauncher() ? 0 : 3)
        }
        let config: LauncherConfiguration
        do {
            config = try JSONDecoder().decode(LauncherConfiguration.self, from: Data(contentsOf: configurationURL()))
            try config.validate()
        } catch {
            showMessage("配置无法读取", "请按住 Shift 打开启动器重新设置，或使用下载包中的重新设置脚本。"); exit(3)
        }
        guard AXIsProcessTrusted() else {
            let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
            _ = AXIsProcessTrustedWithOptions([prompt: true] as CFDictionary)
            showMessage("需要辅助功能权限", "请在系统设置 → 隐私与安全性 → 辅助功能中添加并开启这个启动器。授权后再试。"); exit(2)
        }
        guard let chrome = NSRunningApplication.runningApplications(withBundleIdentifier: "com.google.Chrome").first else {
            exit(launchProfile(config.profileDirectory))
        }
        let wasFrontmost = NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.google.Chrome"
        if !wasFrontmost { chrome.activate(options: [.activateIgnoringOtherApps]) }
        var error: NSDictionary?
        let result = NSAppleScript(source: routeScript(tag: config.windowTag, wasFrontmost: wasFrontmost))?
            .executeAndReturnError(&error).stringValue
        if result == "MINIMIZED" || result == "RAISED" { exit(0) }
        if result == "NOT_FOUND" {
            let app = NSApplication.shared
            app.setActivationPolicy(.accessory); app.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "没有找到命名窗口"
            alert.informativeText = "请把目标 Chrome 窗口命名为“\(config.windowTag)”。\n如果窗口已关闭，可以打开所配置的资料，再为窗口命名。"
            alert.addButton(withTitle: "返回命名")
            alert.addButton(withTitle: "打开资料")
            if alert.runModal() == .alertSecondButtonReturn { exit(launchProfile(config.profileDirectory)) }
            exit(5)
        }
        if result == "AMBIGUOUS" {
            showMessage("窗口名称重复", "请只让一个 Chrome 窗口使用“\(config.windowTag)”这个名称，再试一次。")
        } else {
            showMessage("暂时无法切换窗口", "请检查这个启动器的辅助功能权限，以及“自动化 → System Events（系统事件）”权限。Chrome 的窗口菜单需为中文或英文。没有自动新建窗口。")
        }
        exit(5)
    }
}
