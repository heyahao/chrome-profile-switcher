#!/bin/zsh
set -euo pipefail
project_dir="${0:A:h:h}"
cd "$project_dir"
version="$(< VERSION)"
grep -Fq "## $version — " CHANGELOG.md
grep -Fq "下载 $version 预览版" README.md
stage="$(< .build/latest-build)"
[[ "$stage" == "$project_dir"/.build/apps-* && -d "$stage" ]]
for script in scripts/*.sh scripts/*.command; do /bin/zsh -n "$script"; done
/usr/bin/xcrun swiftc -O src/Configuration.swift tests/ConfigurationTests.swift -o .build/configuration-tests
.build/configuration-tests
python3 tests/RoutingSafetyTests.py
/usr/bin/xcrun swiftc -O src/SafariWindowPolicy.swift tests/SafariWindowPolicyTests.swift -o .build/safari-tests
.build/safari-tests
"$stage/Chrome Work.app/Contents/MacOS/Launcher" --check-script
python3 - "$stage" <<'PY'
import json
from pathlib import Path
import subprocess
import sys
import tempfile

launcher = Path(sys.argv[1]) / 'Chrome Work.app/Contents/MacOS/Launcher'
cases = [
    ({'profileDirectory': 'Default', 'profileMenuName': 'Work'}, 0, 'valid'),
    ({'profileDirectory': 'Profile 2', 'windowTag': 'OldWindow'}, 3, 'configuration-migration-required'),
    ({'profileDirectory': '../Default', 'profileMenuName': 'Work'}, 3, 'invalid configuration'),
]
with tempfile.TemporaryDirectory() as directory:
    for index, (data, code, output) in enumerate(cases):
        path = Path(directory) / f'case-{index}.json'
        path.write_text(json.dumps(data))
        result = subprocess.run([str(launcher), '--validate-config', str(path)], text=True, capture_output=True)
        assert result.returncode == code and result.stdout.strip() == output, 'configuration CLI regression'
print('PASS public launcher CLI configuration/migration checks (no UI or browser interaction)')
PY
for name in 'Chrome Work' 'Chrome Personal' 'Safari Toggle'; do
  app="$stage/$name.app"
  /usr/bin/codesign --verify --deep --strict "$app"
  [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")" == "$version" ]]
  [[ "$(/usr/libexec/PlistBuddy -c 'Print :LSUIElement' "$app/Contents/Info.plist")" == true ]]
  /usr/bin/file "$app/Contents/MacOS/Launcher" | /usr/bin/grep -q 'arm64'
  if /usr/bin/strings "$app/Contents/MacOS/Launcher" | /usr/bin/grep -Eq '/Users/|\.local>|BEGIN .*PRIVATE KEY'; then
    print -u2 'FAIL: private build path or credential marker in binary'; exit 1
  fi
done
print 'PASS native app bundles, signatures, versions and build privacy'
