# 3.0.0 公开预览版检查

检查日期：2026-09-07。该版本以 GitHub **Pre-release（预览版）** 发布，可下载试用；尚未完成另一台 Mac 的首次安装验收。

| 检查面 | 状态 | 证据 / 边界 |
|---|---|---|
| 源码 | changed-and-verified | Swift 编译、配置输入边界/JSON/转义测试、14 项 Safari 决策测试通过 |
| Chrome 脚本 | verified-current | 前后台及含引号、反斜杠、中文名称的 AppleScript 编译检查通过 |
| 应用包 | changed-and-verified | arm64 / macOS 13 最低版本、LSUIElement、独立 Bundle ID、签名完整性检查 |
| 隐私 | changed-and-verified | 公开目录按白名单组装；未复制旧 Git 历史、配置库、运行日志、备份和浏览器图标；源码与包执行模式扫描及人工复核 |
| 使用文档 | changed-and-verified | 下载安装、命名、授权、Manico 手动绑定、重设和卸载步骤已对齐源码 |
| Agent 规则 | changed-and-verified | 只保留公开工程构建/发布约束，无个人运行态 |
| 新安装 GUI / 真实热键 | pending | 当前自动化界面读取连续超时；未将编译通过当作新机 GUI、权限和真实热键验收通过 |
| 签名公证 | pending | 仅 ad-hoc 签名；没有 Apple Developer ID / notarization |
| 其他硬件 / 语言 | out-of-scope | Intel、Windows、Linux，以及非中英文 Chrome 菜单没有覆盖 |
| 生成记忆 | out-of-scope | 未修改宿主管理的记忆文件 |

本项目从作者自用工具整理而来，旧版曾在作者机器验证窗口切换。公开版增加独立身份、首次设置、通用名称和错误处理；旧版验证不能代替本版首次安装测试。

## 发行物验收

打包脚本只收录两个 Chrome App、可选 Safari App、README、MIT LICENSE 与重新设置脚本。源码 ZIP 从公开 Git HEAD 导出。发行校验文件使用 SHA-256；它证明文件完整性，不代表 Apple 公证。

公开 Git 只包含整理后的新历史，署名使用公开 GitHub 用户名与 noreply 邮箱。旧私有仓库没有改成公开，原有本地应用未被覆盖。

## 待完成

在独立测试 Mac 上完成 [手动回归](DEVELOPMENT.md#手动回归)，尤其首次权限申请、全屏/跨桌面、窗口关闭后的重开以及手动全局按键。完成后再把预览版升级为正式推荐版本。
