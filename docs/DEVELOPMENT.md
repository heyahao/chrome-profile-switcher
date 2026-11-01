# 构建与验证

需要 Apple Silicon Mac、macOS 13+ 和 Xcode Command Line Tools。下载 Release 使用现成应用不需要开发工具。

```sh
zsh scripts/build.sh
zsh scripts/verify.sh
zsh scripts/package.sh
```

每次构建使用独立目录，位置记录于 `.build/latest-build`，不会替换已安装应用。发行包位于 `release/`，不进入源码 Git。

## 代码与配置

- `Configuration.swift`：资料目录、精确菜单名称校验，以及旧配置识别。
- `Setup.swift`：首次/升级设置；保存到应用外的 Application Support，原子写入。
- `ChromeRouting.swift`：通过 Chrome 原生个人资料菜单路由、单窗口隐藏/恢复。
- `ChromeProfileLauncher.swift`：配置、权限、共享锁、冷启动、焦点确认和错误处理。
- `SafariWindow*.swift`：可选 Safari 控制；不区分资料。

配置使用 `profileDirectory` 和 `profileMenuName`。3.0.0 的 `windowTag` 不能自动映射为资料名称；升级时重新确认菜单名称，只预填合法旧目录，取消不写入。不要在仓库中提交真实配置。

## 安全边界

- 所有用户名称通过 `appleScriptString` 转义；目录仅接受 `Default` 或 `Profile N`。
- 精确、唯一的资料菜单项由 Chrome 按真实资料路径选择窗口；重复名称、菜单不可用和权限错误不能回退到标题猜测。
- Chrome 运行中只执行一次原生资料菜单动作，不为错误再起 Chrome 进程；普通窗口不存在时由 Chrome 自身创建。
- 前台、资料勾选、普通非全屏主窗口及窗口 ID 复查满足后才隐藏。全屏只定位。
- 两个启动器共用用户临时目录中的锁，避免同时操作。仅确认 Chrome 未运行时使用目录参数冷启动；冷启动不会立即隐藏。
- 激活成功需要资料勾选、可见窗口 ID 连续稳定和系统前台确认。不得把历史超时未经复现就归因为权限或窗口丢失。
- App 使用独立 Bundle ID 和稳定 ad-hoc designated requirement；这不是 Developer ID、公证或跨机器授权保证。

## 验证

自动检查包含配置往返、旧格式迁移拒绝、目录/名称边界、转义、AppleScript 编译、Safari 状态决策、路由保护和签名/隐私扫描。不会自动触发热键、写 TCC、改 Manico 数据库或安装应用。

在独立测试环境手动验证：

1. 首次保存/取消、旧配置升级、升级取消后保留旧文件。
2. 两个资料后台唤起、前台隐藏、恢复原窗口；空窗口名和改名不影响识别。
3. 切换不同桌面，重复触发全屏窗口不隐藏、不退出全屏。
4. 菜单名称重复/不存在、权限撤销时安全报错；没有额外启动 Chrome 进程。
5. Chrome 完全退出后冷启动、目标无普通窗口时由 Chrome 原生流程创建。
6. Manico 实际按键验收：检查系统键盘焦点、目标 ID、窗口数及另一窗口状态；只保留一个热键系统。

**观察器不要执行被测 App 的 `--status` 等命令。** 反复启动同 Bundle ID 的查询进程可能干扰 Manico 对“应用已运行”的判断。热键验收应使用独立观察器，并等待真实状态变化，不能只看进程/锁空闲。命令行诊断仅在空闲排查时手动使用。

`--diagnose` 检查配置菜单项；`--status` 输出资料/窗口 ID；`--debug-state` 输出 AX 状态；`--focus-only` 不隐藏；`--no-alert` 禁止对话框。缺少配置或权限时只读诊断不会弹出设置或启动 Chrome。

## 发布隐私

只从公开 Git HEAD 打包源码；不复制私有历史、个人路径、配置、数据库、日志、备份、屏幕截图或浏览器图标。提交使用公开 GitHub 用户名及 noreply 邮箱。除模式扫描外，还需人工审核 diff、Git 元数据和解压后的最终发行包。
