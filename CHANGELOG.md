# Changelog

## 3.1.0 — 2026-11-01

- Route through Chrome's native Profiles menu instead of named windows. Clearing or changing a window name no longer breaks profile selection.
- Hide only the foreground normal target window and restore it on the next invocation. Fullscreen windows remain fullscreen.
- Reuse Chrome's own profile-to-window routing; Chrome may create a normal window if that profile has none. Do not launch another Chrome process when one is already running.
- Add a shared lock, startup readiness waiting, foreground verification, and state-only local diagnostics. Preserve guarded failure handling; no blind activation retries.
- Replace windowTag with profileMenuName. Upgrading from 3.0.0 requires confirming the exact Profiles-menu name; only a valid old directory is prefilled, and cancel preserves the old file.
- Document independent hotkey observers: launching the tested app to poll its status can interfere with Manico's running-app detection.
- Port the reusable routing improvements from the local 2.6.1 line using fresh public commits; do not import private history, deployment records, configuration or runtime logs.
- Remain a public preview: Apple Silicon/macOS 13+, ad-hoc signed and not notarized. Core controlled tests are not independent-Mac first-run acceptance.

## 3.0.0 — 2026-09-07

First public MIT release.

- Two configurable Chrome launchers: Chrome Work and Chrome Personal.
- First-run setup for the profile directory and the named window.
- Focus an existing named window; minimize the foreground normal window; restore on next launch.
- Match across Spaces through Chrome's Window menu.
- Escape user-entered window names; reject invalid profile paths.
- Ask before opening a profile when its named window cannot be found.
- Optional Safari toggle, with no automatic shortcut registration.
- Separate public app identities, no browser logos, no personal configuration or old private Git history.
- macOS 13+ on Apple Silicon; locally ad-hoc signed, not notarized.
