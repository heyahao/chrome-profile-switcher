# Chrome Profile Switcher

Native macOS launchers for Chrome profiles; optional Safari window toggle.
Version is sourced only from VERSION. Public source, MIT license.

- Build: `zsh scripts/build.sh`. Validate: `zsh scripts/verify.sh`.
- Package: `zsh scripts/package.sh`. Build/release outputs are ignored.
- Swift + AppKit + ApplicationServices; macOS 13+ arm64.
- src/ contains runtime and setup; tests/ contains non-destructive unit checks; docs/ contains guidance.
- Do not copy browser icons, personal configurations, databases, logs, local paths, or private Git history into public artifacts.
- Use fresh public commits with the author's GitHub noreply identity.
- Keep configuration outside app bundles. Escape all user-supplied AppleScript strings.
- Select a unique native Profiles menu item. Missing permissions, duplicate profile names, unavailable menus or failed AX actions must not trigger a second Chrome process; Chrome itself owns normal-window reuse/creation.
- Configuration uses profileDirectory/profileMenuName. Legacy windowTag requires explicit reconfiguration, never reinterpretation as a profile name. Cancel preserves the old file.
- Do not identify profiles from window names, webpage titles or session files. Only the foreground normal target may be hidden; fullscreen only focuses. Preserve the shared lock and stable-focus checks.
- Test observers must not execute the app under test while a Manico hotkey is in flight. Use independent observers and verify actual window/focus changes, not just process completion.
- No automatic modification of Manico databases, login items, TCC, or installed apps.
- Ensure only one hotkey system controls a shortcut; never automatically register global hotkeys.
- Runtime tests change focus: use a controlled window fixture and preserve user data.
- Publish only after artifact and source audits; document unverified platform and notarization limits.
- A release is not proof of first-run permissions on another Mac. Keep that limit explicit.
