import AppKit
import ApplicationServices
import Darwin
import OSLog

private let chromeBundleID = "com.google.Chrome"

private func launchProfile(_ directory: String) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = ["-n", "-b", chromeBundleID, "--args", "--profile-directory=\(directory)"]
    do { try process.run(); process.waitUntilExit(); return process.terminationStatus == 0 }
    catch { return false }
}

@main
struct ChromeProfileLauncher {
    static func main() {
        let args = CommandLine.arguments
        if args.contains("--check-script") {
            for name in ["Work", "Personal", "工作 \"资料\" \\ 示例"] {
                for front in [true, false] {
                    var error: NSDictionary?
                    guard NSAppleScript(source: profileScript(menuName: name, allowToggle: front, diagnose: false))?
                        .compileAndReturnError(&error) == true else {
                        print("script compilation failed"); exit(3)
                    }
                }
            }
            print("PASS native profile scripts and escaped names"); exit(0)
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
            } catch ConfigurationError.migrationRequired {
                print("configuration-migration-required"); exit(3)
            } catch { print("invalid configuration"); exit(3) }
        }
        let diagnose = args.contains("--diagnose")
        let debugState = args.contains("--debug-state")
        let statusOnly = args.contains("--status") || debugState
        let quiet = args.contains("--no-alert") || diagnose || statusOnly
        let configExists = FileManager.default.fileExists(atPath: configurationURL().path)
        if args.contains("--configure") || (!quiet && NSEvent.modifierFlags.contains(.shift)) || !configExists {
            if quiet { print("CONFIGURATION_REQUIRED"); exit(3) }
            exit(configureLauncher() ? 0 : 3)
        }
        let config: LauncherConfiguration
        do {
            config = try JSONDecoder().decode(LauncherConfiguration.self, from: Data(contentsOf: configurationURL()))
            try config.validate()
        } catch ConfigurationError.migrationRequired {
            if quiet { print("CONFIGURATION_MIGRATION_REQUIRED"); exit(3) }
            showMessage("升级后需要确认个人资料名称", "新版不再通过窗口名称定位。请从 Chrome 顶部“个人资料 / Profiles”菜单复制目标名称。原资料目录可以保留；取消不会覆盖旧设置。")
            exit(configureLauncher() ? 0 : 3)
        } catch {
            if quiet { print("CONFIGURATION_INVALID"); exit(3) }
            showMessage("配置无法读取", "请按住 Shift 打开启动器重新设置，或使用下载包中的重新设置脚本。")
            exit(3)
        }
        guard AXIsProcessTrusted() else {
            if !quiet {
                let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
                _ = AXIsProcessTrustedWithOptions([prompt: true] as CFDictionary)
                showMessage("需要辅助功能权限", "请在系统设置 → 隐私与安全性 → 辅助功能中添加并开启这个启动器。授权后再试。")
            }
            print("PERMISSION_REQUIRED"); exit(2)
        }
        let chromeWasFront = NSWorkspace.shared.frontmostApplication?.bundleIdentifier == chromeBundleID
        let chromeWasRunning = !NSRunningApplication.runningApplications(withBundleIdentifier: chromeBundleID).isEmpty
        let lockPath = FileManager.default.temporaryDirectory.appendingPathComponent("chrome-profile-switcher-\(getuid()).lock").path
        let lockFD = open(lockPath, O_CREAT | O_RDWR | O_NOFOLLOW, S_IRUSR | S_IWUSR)
        guard lockFD >= 0 else { print("LOCK_FAILED"); exit(5) }
        guard flock(lockFD, LOCK_EX | LOCK_NB) == 0 else { close(lockFD); print("BUSY"); exit(0) }
        var result: String
        if !chromeWasRunning && (diagnose || statusOnly) {
            result = "CHROME_NOT_RUNNING"
        } else if !chromeWasRunning && !launchProfile(config.profileDirectory) {
            result = "LAUNCH_FAILED"
        } else {
            if !chromeWasRunning {
                for _ in 0..<40 {
                    if executeRoute(profileScript(menuName: config.profileMenuName, allowToggle: false, diagnose: true)) == "FOUND" { break }
                    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
                }
            }
            result = executeRoute(profileScript(menuName: config.profileMenuName,
                allowToggle: chromeWasFront && chromeWasRunning && !args.contains("--focus-only"),
                diagnose: diagnose, statusOnly: statusOnly, debugState: debugState))
        }
        var decisionTrace = ""
        if !diagnose && !statusOnly, let separator = result.firstIndex(of: "|") {
            decisionTrace = String(result[result.index(after: separator)...])
            result = String(result[..<separator])
        }
        let rawScriptResult = result
        if result == "RAISED" {
            for _ in 0..<20 {
                if NSWorkspace.shared.frontmostApplication?.bundleIdentifier == chromeBundleID { break }
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            }
            if NSWorkspace.shared.frontmostApplication?.bundleIdentifier != chromeBundleID { result = "FOCUS_PENDING" }
        }
        flock(lockFD, LOCK_UN)
        close(lockFD)
        if !diagnose && !statusOnly {
            let logger = Logger(subsystem: "io.github.heyahao.chrome-profile-switcher", category: "routing")
            logger.notice("entryChrome=\(chromeWasFront) raw=\(rawScriptResult, privacy: .public) result=\(result, privacy: .public) decision=\(decisionTrace, privacy: .public)")
        }
        print(result)
        if ["HIDDEN", "RAISED", "FOUND"].contains(result) { exit(0) }
        if statusOnly { exit(0) }
        if quiet { exit(5) }
        if result == "PROFILE_NOT_FOUND" || result == "AMBIGUOUS" {
            showMessage("请检查 Chrome 个人资料名称", "在 Chrome 顶部“个人资料 / Profiles”菜单中，需要有且只有一个“\(config.profileMenuName)”。这是资料名称，与“为窗口命名”无关。按住 Shift 打开启动器可重新设置。")
        } else {
            showMessage("暂时无法切换 Chrome 资料", "请确认 Chrome 已就绪，并允许这个启动器访问辅助功能、自动化 → Google Chrome 和 System Events。\n状态：\(result)\n无需修改窗口名称；没有因为错误而另开 Chrome 进程。")
        }
        exit(5)
    }
}
