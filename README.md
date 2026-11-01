# Chrome Profile Switcher

给不同的 Chrome 资料各配一个快捷键：一按切过去，再按隐藏，再按恢复。**窗口改名、页面标题变化，都不影响资料定位。**

**[下载 3.1.0 预览版](https://github.com/heyahao/chrome-profile-switcher/releases/tag/v3.1.0)** · [问题反馈](https://github.com/heyahao/chrome-profile-switcher/issues) · [MIT 许可证](LICENSE)

适用于 Apple Silicon Mac、macOS 13 或更新版本。需要自行安装 Google Chrome 和 Manico；本工具不常驻、不注册全局快捷键，也不需要浏览器扩展。Intel、Windows 和 Linux 暂不支持。

这是公开预览版：构建、配置迁移、脚本及签名检查已通过；独立 Mac 上的首次设置、授权和真实热键仍待验收。程序使用 ad-hoc 签名，没有 Apple Developer ID 公证。

## 从 3.0.0 升级

把新文件夹放回原来的安装位置。首次打开两个 Chrome 启动器时，分别确认一次 **Chrome 个人资料菜单中的名称**。

3.0.0 保存的是窗口名称，3.1.0 不会把它当成资料名。设置框会保留合法的旧资料目录，资料名称需要重新填写；取消不会覆盖旧配置。原来的窗口名称可以保留或删掉，都不会用于定位。快捷键不会被自动修改。

## 1. 下载并放好

在下载页的 **Assets** 中选择 `Chrome-Profile-Switcher-3.1.0-macOS-arm64.zip`，想直接使用就选这个 ZIP，不用下载 Source code。

解压，把 **Chrome Profile Switcher** 整个文件夹拖进 Finder 的“应用程序”：

| 文件 | 用途 |
|---|---|
| Chrome Work.app | 控制第一个 Chrome 资料 |
| Chrome Personal.app | 控制第二个 Chrome 资料 |
| Optional/Safari Toggle.app | 可选的 Safari 窗口控制 |
| 重新设置.command | 以后修改两个 Chrome 启动器的配置 |

请始终从同一个安装位置打开和添加到 Manico，不要绑定下载目录或旧副本。配置保存在应用外，正常覆盖升级不会删除设置。

## 2. 告诉它要控制哪个资料

以 `Chrome Work.app` 为例：

1. 打开目标 Chrome 资料，在地址栏输入 `chrome://version`。
2. 找到“个人资料路径 / Profile Path”，只复制最后一段，例如 `Default` 或 `Profile 2`。不要填完整路径或邮箱。
3. 打开 Chrome 顶部 **个人资料 / Profiles** 菜单，记下目标条目的完整名称，包括空格、括号等。
4. 双击 `Chrome Work.app`。资料目录填第 2 步的值，个人资料菜单名称填第 3 步的文字，保存。
5. 再用 `Chrome Personal.app` 设置另一个资料。两个启动器使用不同的资料。

例如菜单里显示“工作”，就填“工作”。**不用再执行“窗口 → 为窗口命名”。** 菜单中必须只有一个条目匹配该名称；同名资料请先在 Chrome 中改成不同名称。

## 3. 给权限

在 **系统设置 → 隐私与安全性 → 辅助功能** 中添加并开启 `Chrome Work` 和 `Chrome Personal`。

首次请求控制 **Google Chrome** 和 **System Events / 系统事件** 时选择允许；之后可在“自动化”中检查。权限要分别给两个启动器，只给 Chrome 或 Manico 不够。执行完立即退出、没有 Dock 窗口，都是正常的。

若 macOS 提示无法验证开发者，请先核对下载来自本仓库，再参考 [Apple 的官方说明](https://support.apple.com/en-us/102445)处理首次打开。可用 Release 的 `SHA256SUMS.txt` 验证下载完整性；它不代表 Apple 公证。不要关闭 Gatekeeper。公司管理的 Mac 可能限制此类应用。

## 4. 在 Manico 里绑定快捷键

进入 Manico **配置 → 自定义 → App**，添加固定安装位置里的两个 Chrome 启动器；再到“快捷键”页录制喜欢的组合，例如：

| 示例 | 对应应用 |
|---|---|
| Control+A | Chrome Work |
| Control+D | Chrome Personal |

这些只是示例，工具不会自动占用按键。一个快捷键只保留一套控制程序；旧热键脚本或登录启动项同时响应时，可能出现“刚隐藏又弹回”。

## 平时怎么用

- 目标资料在后台或另一个桌面：按快捷键切过去。
- 目标普通窗口已在前台：再按一次单独隐藏，再按恢复，不走 Dock 最小化。
- 全屏窗口：只定位，不隐藏或强制退出全屏。
- 对应普通窗口已关闭：Chrome 原生资料切换会打开该资料的普通窗口。
- Chrome 完全未运行：按配置的资料目录启动，再等待资料菜单就绪。
- 窗口名清空、改名或显示音频图标：不影响资料定位。
- 修改了 **资料名称**：按住 Shift 打开启动器，或运行“重新设置.command”，更新配置。

同一资料开了多个普通窗口时，由 Chrome 选择要激活的窗口；本工具不固定某一个。同资料只有无痕、PWA 或弹出窗口时，Chrome 可能另开一个普通窗口。菜单仅覆盖简体中文和英文，权限、锁定资料或 Chrome 更新也可能影响切换。

## Safari 可选

`Optional/Safari Toggle.app` 控制 Safari 当前/最近窗口，不区分 Safari 资料。可单独添加到辅助功能和 Manico，再选择一个不冲突的快捷键；工具不会自动绑定。普通窗口支持最小化/恢复，全屏只聚焦，不需要 System Events 自动化权限。

## 排错与卸载

- 找不到个人资料：核对“个人资料 / Profiles”菜单里的完整名称，确认名称唯一；不要改窗口名。
- 没有反应：核对 Manico 的固定路径，以及两个启动器各自的辅助功能、Google Chrome / System Events 自动化权限。
- 焦点等待超时：等桌面切换或 Chrome 启动结束再试。单次超时不代表窗口丢失；工具不会因为激活失败重复点击资料项或另起 Chrome 进程。
- 刚隐藏又弹回：检查重复热键工具或登录项。
- 卸载：先在 Manico 移除绑定，再把应用文件夹移到废纸篓。可按需删除 `~/Library/Application Support/Chrome Profile Switcher/` 中的设置。不会安装登录启动项。

## 隐私与开源

配置只保存在你的 Mac 上。本工具没有联网、统计或上传代码，不读取网页正文、浏览记录或会话文件，也不使用窗口名称识别资料。

Chrome 本地诊断记录布尔状态、结果码和 AX 错误码，不含资料名称、网页标题或网址。`--status` 和 Safari 诊断可输出本机窗口标识；分享诊断前仍请检查。不要把个人配置或完整系统日志提交到 Issue。

源码和本项目编译出的程序使用 **MIT**，可使用、修改、再发布或商用，保留许可证和版权声明即可。Chrome、Safari、Manico 属于各自权利人，本项目不附带它们的软件或图标，也不代表官方。

开发者见 [构建与验证](docs/DEVELOPMENT.md)，验收范围见 [发布检查](docs/RELEASE-CHECK.md)。
