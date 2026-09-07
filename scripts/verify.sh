#!/bin/zsh
set -euo pipefail
project_dir="${0:A:h:h}"
cd "$project_dir"
version="$(< VERSION)"
stage="$(< .build/latest-build)"
[[ "$stage" == "$project_dir"/.build/apps-* && -d "$stage" ]]
for script in scripts/*.sh scripts/*.command; do /bin/zsh -n "$script"; done
/usr/bin/xcrun swiftc -O src/Configuration.swift tests/ConfigurationTests.swift -o .build/configuration-tests
.build/configuration-tests
/usr/bin/xcrun swiftc -O src/SafariWindowPolicy.swift tests/SafariWindowPolicyTests.swift -o .build/safari-tests
.build/safari-tests
"$stage/Chrome Work.app/Contents/MacOS/Launcher" --check-script
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
