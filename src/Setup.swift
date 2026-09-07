import AppKit

func configurationURL() -> URL {
    FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Chrome Profile Switcher")
        .appendingPathComponent((Bundle.main.bundleIdentifier ?? "unknown") + ".json")
}

func showMessage(_ title: String, _ message: String) {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    app.activate(ignoringOtherApps: true)
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.addButton(withTitle: "好")
    alert.runModal()
}

func configureLauncher() -> Bool {
    let old = (try? Data(contentsOf: configurationURL())).flatMap {
        try? JSONDecoder().decode(LauncherConfiguration.self, from: $0)
    }
    let slot = Bundle.main.object(forInfoDictionaryKey: "LauncherSlot") as? String ?? "work"
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    app.activate(ignoringOtherApps: true)
    let alert = NSAlert()
    alert.messageText = "设置 " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Chrome")
    alert.informativeText = "① 在目标 Chrome 资料打开 chrome://version，复制“个人资料路径”最后一段。\n② 在 Chrome 的“窗口 → 为窗口命名”中，把目标窗口命名为下方相同名称。每个启动器使用不同名称。\n保存后关闭设置，再次打开启动器即可切换。"
    let panel = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 110))
    let directory = NSTextField(frame: NSRect(x: 0, y: 65, width: 380, height: 24))
    directory.stringValue = old?.profileDirectory ?? (slot == "work" ? "Default" : "Profile 1")
    let tag = NSTextField(frame: NSRect(x: 0, y: 5, width: 380, height: 24))
    tag.stringValue = old?.windowTag ?? (slot == "work" ? "WorkWindow" : "PersonalWindow")
    for (label, y) in [("资料目录（不是邮箱或昵称）", 90.0), ("窗口名称（不是资料名称）", 30.0)] {
        let field = NSTextField(labelWithString: label)
        field.frame = NSRect(x: 0, y: y, width: 380, height: 20)
        panel.addSubview(field)
    }
    panel.addSubview(directory); panel.addSubview(tag)
    alert.accessoryView = panel
    alert.addButton(withTitle: "保存"); alert.addButton(withTitle: "取消")
    guard alert.runModal() == .alertFirstButtonReturn else { return false }
    do {
        let config = LauncherConfiguration(profileDirectory: directory.stringValue.trimmingCharacters(in: .whitespaces),
            windowTag: tag.stringValue.trimmingCharacters(in: .whitespaces))
        try config.validate()
        let url = configurationURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(config).write(to: url, options: [.atomic])
        return true
    } catch {
        showMessage("设置未保存", error.localizedDescription)
        return false
    }
}
