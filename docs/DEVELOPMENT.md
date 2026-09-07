# 构建与验证

需要 Apple Silicon Mac、macOS 13+、Xcode Command Line Tools（包含 Swift 编译器）。下载 Release 使用现成应用，不需要安装开发工具。

```sh
zsh scripts/build.sh
zsh scripts/verify.sh
zsh scripts/package.sh
```

输出位置由 `.build/latest-build` 记录，每次构建使用独立目录；不会替换应用程序目录中的现有安装。`release/` 只保存发行包，不进入源码 Git。

## 目录

- `src/Configuration.swift`：配置校验和 AppleScript 字符串转义。
- `src/Setup.swift`：首次设置，JSON 原子写入用户 Application Support。
- `src/ChromeProfileLauncher.swift`：命名窗口路由和正常窗口最小化。
- `src/SafariWindow*.swift`：可选 Safari 控制。
- `tests/`：配置边界、序列化、Safari 状态决策测试。
- `scripts/`：可重复构建、签名检查、打包和公开内容检查。

## 安全边界

不要仅凭当前 Space 的 AXWindows 为空就新建 Chrome 窗口；先检查窗口菜单。找不到命名窗口时由用户明确选择是否打开资料。名称重复、权限错误及菜单不可用时失败退出。

窗口名称必须经过 `appleScriptString` 转义；资料目录只允许 `Default` 或 `Profile N`，不接受完整路径或任意参数。配置在应用包外，修改配置不会破坏签名。

App 使用独立 Bundle ID 和稳定的 ad-hoc designated requirement。Ad-hoc 签名只用于本地完整性检查，不是 Apple Developer ID 或公证，不保证跨系统升级后自动继承辅助功能权限。

## 手动回归

在独立测试窗口中配置两个不同名称，逐项验证：

1. 初次设置可保存/取消，重开能读回设置。
2. 前后台切换、同窗口收起/恢复、不同桌面切换，窗口数量不变。
3. 全屏只聚焦，重复名称报错。
4. 目标未命名时先提示，不自动新建；取消后窗口数量不变。
5. 撤销权限后报错，不新建窗口。
6. 只保留一个热键系统。真实全局按键需要授权的输入宿主或人工操作；不能用普通终端合成键无响应推断失败。

辅助功能和其他软件的启动权限需要用户在系统设置中授予。CI 的纯测试不能替代这一部分。
