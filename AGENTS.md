# Chrome Profile Switcher

Native macOS launchers for named Chrome windows; optional Safari window toggle.
Version is sourced only from VERSION. Public source, MIT license.

- Build: `zsh scripts/build.sh`. Validate: `zsh scripts/verify.sh`.
- Package: `zsh scripts/package.sh`. Build/release outputs are ignored.
- Swift + AppKit + ApplicationServices; macOS 13+ arm64.
- src/ contains runtime and setup; tests/ contains non-destructive unit checks; docs/ contains guidance.
- Do not copy browser icons, personal configurations, databases, logs, local paths, or private Git history into public artifacts.
- Use fresh public commits with the author's GitHub noreply identity.
- Keep configuration outside app bundles. Escape all user-supplied AppleScript strings.
- Missing permissions, failed window enumeration, duplicate tags, or failed AX actions must not silently create Chrome windows.
- No automatic modification of Manico databases, login items, TCC, or installed apps.
- Ensure only one hotkey system controls a shortcut; never automatically register global hotkeys.
- Runtime tests change focus: use a controlled window fixture and preserve user data.
- Publish only after artifact and source audits; document unverified platform and notarization limits.
- A release is not proof of first-run permissions on another Mac. Keep that limit explicit.
