#!/bin/zsh
set -euo pipefail
project_dir="${0:A:h:h}"
cd "$project_dir"
version="$(< VERSION)"
[[ "$version" == <->.<->.<-> ]]
mkdir -p .build
stage=$(/usr/bin/mktemp -d "$project_dir/.build/apps-XXXXXX")
common=(-O -target arm64-apple-macosx13.0 -debug-prefix-map "$project_dir=/src")
/usr/bin/xcrun swiftc "${common[@]}" src/Configuration.swift src/Setup.swift src/ChromeRouting.swift src/ChromeProfileLauncher.swift -o "$stage/chrome"
/usr/bin/xcrun swiftc "${common[@]}" src/SafariWindowPolicy.swift src/SafariWindowLauncher.swift -o "$stage/safari"
make_app() {
  local name="$1" id="$2" binary="$3" slot="$4"
  local app="$stage/$name.app"
  mkdir -p "$app/Contents/MacOS"
  cp "$stage/$binary" "$app/Contents/MacOS/Launcher"
  /usr/bin/plutil -create xml1 "$app/Contents/Info.plist"
  /usr/libexec/PlistBuddy \
    -c "Add :CFBundleExecutable string Launcher" \
    -c "Add :CFBundleIdentifier string $id" \
    -c "Add :CFBundleName string $name" \
    -c "Add :CFBundleDisplayName string $name" \
    -c "Add :CFBundlePackageType string APPL" \
    -c "Add :CFBundleShortVersionString string $version" \
    -c "Add :CFBundleVersion string $version" \
    -c 'Add :LSMinimumSystemVersion string 13.0' \
    -c 'Add :LSUIElement bool true' \
    -c "Add :LauncherSlot string $slot" \
    -c 'Add :NSAppleEventsUsageDescription string 用于通过 Chrome 个人资料菜单切换，并单独隐藏或恢复对应窗口。' \
    "$app/Contents/Info.plist"
  /usr/bin/codesign --force --sign - --requirements "=designated => identifier \"$id\"" "$app"
}
make_app 'Chrome Work' 'io.github.heyahao.chrome-profile-switcher.work' chrome work
make_app 'Chrome Personal' 'io.github.heyahao.chrome-profile-switcher.personal' chrome personal
make_app 'Safari Toggle' 'io.github.heyahao.chrome-profile-switcher.safari' safari safari
print -r -- "$stage" > .build/latest-build
print "Built apps: $stage"
