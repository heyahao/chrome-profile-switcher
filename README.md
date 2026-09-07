# Chrome Profile Switcher

给不同的 Chrome 资料各配一个快捷键：工作窗口、私人窗口，一按就到。已经在目标窗口时，再按一次收起，再按恢复。

**[下载 3.0.0 预览版](https://github.com/heyahao/chrome-profile-switcher/releases/tag/v3.0.0)** · [遇到问题](https://github.com/heyahao/chrome-profile-switcher/issues) · [MIT 许可证](LICENSE)

当前是公开预览版：编译、配置与状态测试、签名和隐私检查已通过；首次安装 GUI、权限和真实快捷键仍需独立 Mac 验收。欢迎按下面步骤试用并反馈。

适合同时使用两个 Chrome 资料、经常在不同桌面切换的人。工具提供两个小应用，快捷键交给你已有的 Manico 管理。它自己不常驻、不注册快捷键，也不需要浏览器扩展。

## 先看这三点

- 下载包适用于 **Apple Silicon Mac（M1/M2/M3/M4 等）、macOS 13 或更新版本**。Intel、Windows、Linux 暂不支持。
- 需要自行安装 Google Chrome 和 Manico。它们不包含在下载包里，Manico 的授权由其开发者提供。
- 首次使用需要设置两个字段并授权。之后正常切换没有“运行脚本”的弹窗。当前版本没有 Apple Developer ID 签名/公证，首次打开可能需要手动确认，见下文。

## 1. 下载并放好

进入上方下载页，在 **Assets** 中下载 `Chrome-Profile-Switcher-3.0.0-macOS-arm64.zip`。想直接用，就选这个 ZIP，不用下载 Source code。

解压，把里面的 **Chrome Profile Switcher** 整个文件夹拖进 Finder 的“应用程序”。里面有：

| 文件 | 用途 |
|---|---|
| Chrome Work.app | 控制你的第一个 Chrome 资料窗口 |
| Chrome Personal.app | 控制你的第二个 Chrome 资料窗口 |
| Optional/Safari Toggle.app | 可选：控制 Safari，不用就不配置 |
| 重新设置.command | 以后修改 Chrome 对应资料或窗口名称 |

请从“应用程序”里的固定位置打开和添加到 Manico，不要绑定下载目录里的副本。升级时也放回同一位置，个人设置保存在应用外面。

## 2. 告诉它要找哪个窗口

以工作资料为例：

1. 打开你准备控制的 Chrome 资料，在地址栏输入 `chrome://version`。
2. 找到“个人资料路径 / Profile Path”，只记下最后一段，例如 `Default` 或 `Profile 2`。**不是邮箱，也不是资料昵称**；两个资料的目录不一定恰好是 Default 和 Profile 1。
3. 在这个 Chrome 窗口的顶部菜单选择 **窗口 → 为窗口命名（Window → Name Window）**，命名为 `WorkWindow`。有些 Chrome 版本也能在窗口顶部空白处右键找到此项。
4. 双击 `Chrome Work.app`，首次会显示设置框。资料目录填刚才的最后一段；窗口名称填 `WorkWindow`，点击“保存”。
5. 另一个资料同样操作：使用它自己的目录，把窗口命名为 `PersonalWindow`，在 `Chrome Personal.app` 中保存。

`WorkWindow` 和 `PersonalWindow` 只是方便上手的示例，你可以换成中文等自定义名称。每个名称应只对应一个窗口；资料昵称和窗口名称是两件事。

**为什么还要命名？** Chrome 在另一个桌面时，不一定会把窗口暴露给普通窗口列表。通过“窗口”菜单里的唯一名称，才能可靠地找到你要的那个窗口。

## 3. 给权限

再次打开启动器时，按提示在 **系统设置 → 隐私与安全性 → 辅助功能** 中添加并开启 `Chrome Work` 和 `Chrome Personal`。首次请求控制 **System Events / 系统事件** 时选择允许；之后可在“自动化”中检查。

权限要给这两个小应用；只给 Chrome 或 Manico 不够。启动器正常执行完会立即退出，没有 Dock 窗口是正常的。

如果 macOS 提示开发者无法验证：先确认下载来自本仓库，可以用 Release 的 `SHA256SUMS.txt` 检查下载是否完整。尝试打开一次后，按 [Apple 官方说明](https://support.apple.com/en-us/102445)，在“隐私与安全性”中查看“仍要打开”。不要关闭 Gatekeeper，也不要给来源不明的副本授权。公司管理的 Mac 可能不允许此操作。

## 4. 在 Manico 里加快捷键

打开 Manico 设置，进入 **配置 → 自定义 → App**，添加“应用程序”文件夹里的 `Chrome Work.app` 和 `Chrome Personal.app`；再去 **快捷键** 页录制喜欢的组合。例如：

| 快捷键示例 | 对应应用 |
|---|---|
| Control+A | Chrome Work |
| Control+D | Chrome Personal |

这是示例，不会自动占用你的按键。已经分配给其他软件的组合要先解除冲突。同一个快捷键只能让一套切换工具接管，尤其检查旧版启动器、后台热键脚本和登录启动项；两套同时响应，会出现“刚收起又弹回”。

## 平时怎么用

- 目标窗口在后台：按快捷键切过去；在另一个桌面也通过命名窗口切换。
- 已在目标普通窗口：再按收起，再按恢复。
- 全屏窗口：只切换/聚焦，不强制退出全屏或最小化。
- Chrome 没运行：打开你设置的资料。
- Chrome 正在运行，但没有找到命名窗口：提示你先命名；如果窗口已关闭，可在提示里选择“打开资料”，然后为新窗口命名。
- 重启 Chrome 后若它没有保留窗口名称，重新命名即可。工具不会把任意未命名窗口当成你的目标，也不会修改书签、账号或历史记录。

目前窗口菜单支持中文和英文。Chrome 更新可能改变辅助功能行为；如发现仅显示菜单或没有切换，请反馈版本和复现步骤。

## Safari 是可选的

把 `Optional/Safari Toggle.app` 单独添加到辅助功能及 Manico，可以给它配另一个快捷键。它控制 Safari 当前/最近窗口，**不区分 Safari 资料**。普通窗口支持收起/恢复，全屏只聚焦；多窗口时优先恢复上次由它收起的窗口。它不需要 System Events 自动化权限。

不想用 Safari 功能，跳过即可；它不会自动绑定 `Control+S`。

## 修改配置、卸载和排错

- 改设置：双击下载包中的“重新设置.command”，选择 1 或 2；也可按住 Shift 打开对应启动器。
- 授权后仍无响应：确认 Manico 引用的是固定安装位置，并检查两个启动器各自的权限。更新签名或移动位置后，系统可能要求重新添加授权。
- 一按收起又弹回：检查其他软件、旧版后台或登录项是否也监听相同快捷键，停用重复入口。
- 一直说找不到窗口：核对窗口名称逐字一致，且你是在目标资料中命名；确认 Chrome 菜单为中文/英文。
- 卸载：先在 Manico 移除这两个绑定，再把应用文件夹移到废纸篓。可按需删除 `~/Library/Application Support/Chrome Profile Switcher/` 中的设置。工具不会安装登录启动项。

## 隐私和开源

配置只存在你的 Mac 上。工具不联网、不收集统计，不上传窗口标题或浏览记录。切换时会读取 Chrome 窗口名称；Safari 的诊断命令会输出本机窗口标识，所以反馈日志前仍请检查。

源码与本项目编译出的程序使用 **MIT**：可以使用、修改、再发布或商用，保留许可证和版权声明即可。Chrome、Safari、Manico 属于各自权利人，本项目不附带它们的软件或图标，也不代表官方。

开发者见 [构建与验证](docs/DEVELOPMENT.md)，当前验收范围见 [发布检查](docs/RELEASE-CHECK.md)。
