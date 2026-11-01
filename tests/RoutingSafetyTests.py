"""Regression guard for profile identity, failure paths and privacy boundaries."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
route = (root / "src/ChromeRouting.swift").read_text()
entry = (root / "src/ChromeProfileLauncher.swift").read_text()
for forbidden in ("given name", "windowTag", "key code", "keystroke", "AXMinimized", "Sessions/"):
    assert forbidden not in route, forbidden
assert route.count('perform action "AXPress"') == 1
assert route.index('if (count of targets) is not 1 then return "AMBIGUOUS"') < route.index('perform action "AXPress"')
assert 'appleScriptString(menuName)' in route
assert 'attribute "AXFullScreen" of w) is false' in route
assert '(id of front window) is targetID' in route
assert 'if previousID is targetID then return "RAISED|' in route
assert 'LOCK_EX | LOCK_NB' in entry
assert '!chromeWasRunning && !launchProfile(config.profileDirectory)' in entry
assert 'chromeWasFront && chromeWasRunning' in entry
assert 'catch ConfigurationError.migrationRequired' in entry
assert 'if quiet { print("CONFIGURATION_MIGRATION_REQUIRED"); exit(3) }' in entry
assert 'config.profileMenuName' not in next(line for line in entry.splitlines() if 'logger.notice' in line)
print("PASS profile identity, duplicate/fullscreen/failure guards and state-only logging")
