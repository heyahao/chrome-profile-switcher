// 纯状态决策；版本由 VERSION 管理。独立于辅助功能，便于覆盖错误与多窗口场景。
struct SafariWindowState {
    let identifier: String
    let isMain: Bool
    let isMinimized: Bool
    let isFullScreen: Bool
    let isStandard: Bool
}

enum SafariWindowAction: Equatable {
    case minimize(Int)
    case focus(Int)
    case activate
    case reopen
}

func safariWindowAction(
    windows: [SafariWindowState],
    wasFrontmost: Bool,
    windowListReliable: Bool,
    minimizedByLauncher: String?
) -> SafariWindowAction {
    // 优先还原上次由本启动器收起的同一个窗口，避免多窗口时轮流最小化。
    if let remembered = minimizedByLauncher, !remembered.isEmpty,
       let index = windows.firstIndex(where: { $0.identifier == remembered && $0.isMinimized }) {
        return .focus(index)
    }
    if let main = windows.firstIndex(where: { $0.isMain && !$0.isMinimized }) {
        let state = windows[main]
        if wasFrontmost && state.isStandard && !state.isFullScreen {
            return .minimize(main)
        }
        return .focus(main)
    }
    if let index = windows.firstIndex(where: { $0.isStandard && !$0.isMinimized }) {
        return .focus(index)
    }
    if let index = windows.firstIndex(where: { $0.isStandard }) {
        return .focus(index)
    }
    // Safari 在最小化后可能把普通窗口暂报为 AXDialog，仍须支持手动最小化后的恢复。
    if let index = windows.firstIndex(where: { $0.isMinimized }) {
        return .focus(index)
    }
    // 对话框不当作普通浏览器窗口处理；只激活，不关闭、不最小化。
    if !windows.isEmpty || !windowListReliable { return .activate }
    return .reopen
}
