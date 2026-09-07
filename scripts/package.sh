#!/bin/zsh
set -euo pipefail
project_dir="${0:A:h:h}"
cd "$project_dir"
version="$(< VERSION)"
stage="$(< .build/latest-build)"
[[ "$stage" == "$project_dir"/.build/apps-* && -d "$stage" ]]
zsh scripts/verify.sh
python3 scripts/audit-public.py .
mkdir -p release
release_name="Chrome-Profile-Switcher-$version-macOS-arm64"
zip_path="$project_dir/release/$release_name.zip"
[[ ! -e "$zip_path" ]] || { print -u2 'Release exists; choose a new VERSION or archive the previous package first.'; exit 1; }
package_root=$(/usr/bin/mktemp -d "$project_dir/.build/package-XXXXXX")
package="$package_root/Chrome Profile Switcher"
mkdir -p "$package/Optional"
/usr/bin/ditto "$stage/Chrome Work.app" "$package/Chrome Work.app"
/usr/bin/ditto "$stage/Chrome Personal.app" "$package/Chrome Personal.app"
/usr/bin/ditto "$stage/Safari Toggle.app" "$package/Optional/Safari Toggle.app"
cp README.md LICENSE "$package/"
cp -R docs "$package/docs"
cp scripts/reconfigure.command "$package/重新设置.command"
chmod +x "$package/重新设置.command"
python3 scripts/audit-public.py "$package"
COPYFILE_DISABLE=1 /usr/bin/ditto -c -k --norsrc --noextattr --keepParent "$package" "$zip_path"
git diff --quiet && git diff --cached --quiet || { print -u2 'Commit source changes before packaging source ZIP.'; exit 1; }
git archive --format=zip --prefix="chrome-profile-switcher-$version/" \
  -o "release/Chrome-Profile-Switcher-$version-source.zip" HEAD
(cd release && /usr/bin/shasum -a 256 "$release_name.zip" "Chrome-Profile-Switcher-$version-source.zip" > SHA256SUMS.txt)
print "Packaged: $zip_path"
