#!/bin/zsh
set -euo pipefail
print '选择要重新设置的启动器：1 = Chrome Work，2 = Chrome Personal'
read 'slot?输入 1 或 2，然后回车：'
case "$slot" in
  1) app_name='Chrome Work' ;;
  2) app_name='Chrome Personal' ;;
  *) print '没有修改。'; exit 1 ;;
esac
for candidate in "/Applications/Chrome Profile Switcher/$app_name.app" "$HOME/Applications/Chrome Profile Switcher/$app_name.app"; do
  if [[ -d "$candidate" ]]; then
    /usr/bin/open -n "$candidate" --args --configure
    exit 0
  fi
done
print '未找到应用。请先把 Chrome Profile Switcher 文件夹放入“应用程序”。'
exit 1
