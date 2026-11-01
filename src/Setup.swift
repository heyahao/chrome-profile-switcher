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
    let oldData = try? Data(contentsOf: configurationURL())
    let old = oldData.flatMap {
        try? JSONDecoder().decode(LauncherConfiguration.self, from: $0)
    }
    let legacyDirectory = oldData.flatMap { LauncherConfiguration.legacyProfileDirectory(from: $0) }
    let slot = Bundle.main.object(forInfoDictionaryKey: "LauncherSlot") as? String ?? "work"
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    app.activate(ignoringOtherApps: true)
    let alert = NSAlert()
    alert.messageText = "设置 " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Chrome")
    alert.informativeText = (legacyDirectory == nil ? "" : "旧版配置需要重新设置；已保留资料目录供核对，请重新填写资料名称。取消不会修改旧配置。\n\n") + "① 在目标 Chrome 资料打开 chrome://version，复制“个人资料路径”最后一段。\n② 从 Chrome 顶部“个人资料 / Profiles”菜单复制目标资料的精确显示名称，保留空格和标点。名称必须唯一，不能使用旧窗口名称。\n保存后关闭设置，再次打开启动器即可切换。"
    let panel = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 110))
    let directory = NSTextField(frame: NSRect(x: 0, y: 65, width: 380, height: 24))
    directory.stringValue = old?.profileDirectory ?? legacyDirectory ?? (slot == "work" ? "Default" : "Profile 1")
    let menuName = NSTextField(frame: NSRect(x: 0, y: 5, width: 380, height: 24))
    menuName.stringValue = old?.profileMenuName ?? ""
    menuName.placeholderString = slot == "work" ? "例如 Work，请填写菜单实际名称" : "例如 Personal，请填写菜单实际名称"
    for (label, y) in [("资料目录（不是邮箱或昵称）", 90.0), ("个人资料菜单中的精确显示名称", 30.0)] {
        let field = NSTextField(labelWithString: label)
        field.frame = NSRect(x: 0, y: y, width: 380, height: 20)
        panel.addSubview(field)
    }
    panel.addSubview(directory); panel.addSubview(menuName)
    alert.accessoryView = panel
    alert.addButton(withTitle: "保存"); alert.addButton(withTitle: "取消")
    guard alert.runModal() == .alertFirstButtonReturn else { return false }
    do {
        let config = LauncherConfiguration(profileDirectory: directory.stringValue.trimmingCharacters(in: .whitespaces),
            profileMenuName: menuName.stringValue)
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
