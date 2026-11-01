import AppKit

// Profile routing never uses webpage titles, named windows, or session files.
func profileScript(menuName: String, allowToggle: Bool, diagnose: Bool, statusOnly: Bool = false, debugState: Bool = false) -> String {
    """
    tell application "System Events"
      tell process "Google Chrome"
        set profileMenu to missing value
        repeat with mb in menu bar items of menu bar 1
          if name of mb is in {"个人资料", "Profiles", "用户", "People"} then
            set profileMenu to menu 1 of mb
            exit repeat
          end if
        end repeat
        if profileMenu is missing value then return "PROFILE_MENU_UNAVAILABLE"
        set targets to every menu item of profileMenu whose name is \(appleScriptString(menuName))
        if (count of targets) is 0 then return "PROFILE_NOT_FOUND"
        if (count of targets) is not 1 then return "AMBIGUOUS"
        if \(diagnose ? "true" : "false") then return "FOUND"
        set targetItem to item 1 of targets
        set isCurrentProfile to false
        try
          set isCurrentProfile to (value of attribute "AXMenuItemMarkChar" of targetItem as text) is "✓"
        end try
        if \(statusOnly ? "true" : "false") then
          if \(debugState ? "true" : "false") then
            set details to "current=" & (isCurrentProfile as text) & "|front=" & (frontmost as text)
            repeat with w in windows
              try
                set details to details & "|" & (value of attribute "AXMain" of w as text) & ":" & (value of attribute "AXSubrole" of w as text) & ":" & (value of attribute "AXFullScreen" of w as text)
              end try
            end repeat
            return details
          end if
          if not isCurrentProfile then return "OTHER_PROFILE"
          tell application "Google Chrome"
            if (count of windows) is 0 then return "NO_WINDOW"
            return "CURRENT:" & (id of front window as text)
          end tell
        end if
        set mayHide to false
        set hideProbeError to 0
        if \(allowToggle ? "true" : "false") and isCurrentProfile then
          repeat with w in windows
            try
              if (value of attribute "AXMain" of w) is true and (value of attribute "AXSubrole" of w as text) is "AXStandardWindow" then
                if (value of attribute "AXFullScreen" of w) is false then set mayHide to true
                exit repeat
              end if
            on error errorMessage number errorNumber
              set hideProbeError to errorNumber
            end try
          end repeat
        end if
      end tell
    end tell
    set decisionTrace to "selected=" & (isCurrentProfile as text) & ",eligible=" & (mayHide as text) & ",axError=" & (hideProbeError as text)
    if mayHide then
      tell application "Google Chrome"
        set targetID to -1
        if (count of windows) > 0 then set targetID to id of front window
      end tell
      -- Recheck after obtaining the ID: a concurrent focus change must not hide another profile.
      tell application "System Events" to tell process "Google Chrome"
        set mayHide to false
        try
          set refreshedTargets to every menu item of profileMenu whose name is \(appleScriptString(menuName))
          if frontmost and (count of refreshedTargets) is 1 then
            set mayHide to (value of attribute "AXMenuItemMarkChar" of item 1 of refreshedTargets as text) is "✓"
          end if
        end try
      end tell
      set decisionTrace to decisionTrace & ",rechecked=" & (mayHide as text)
      tell application "Google Chrome"
        if mayHide and (count of windows) > 0 then
          if (id of front window) is targetID and (visible of window id targetID) and not (minimized of window id targetID) then
            set visible of window id targetID to false
            if not (visible of window id targetID) then return "HIDDEN|" & decisionTrace
            return "HIDE_FAILED"
          end if
        end if
      end tell
    end if
    tell application "Google Chrome" to activate
    tell application "System Events" to tell process "Google Chrome"
      perform action "AXPress" of targetItem
    end tell
    -- Native profile switching owns reuse/creation; allow its activation to settle.
    set previousID to -1
    repeat 40 times
      tell application "System Events" to tell process "Google Chrome"
        set isCurrentProfile to false
        try
          set refreshedTargets to every menu item of profileMenu whose name is \(appleScriptString(menuName))
          if (count of refreshedTargets) is 1 then set isCurrentProfile to (value of attribute "AXMenuItemMarkChar" of item 1 of refreshedTargets as text) is "✓"
        end try
        set isFront to frontmost
      end tell
      if isCurrentProfile and isFront then
        tell application "Google Chrome"
          if (count of windows) > 0 then
            set targetID to id of front window
            if not (visible of window id targetID) then set visible of window id targetID to true
            if minimized of window id targetID then set minimized of window id targetID to false
            if visible of window id targetID then
              if previousID is targetID then return "RAISED|" & decisionTrace
              set previousID to targetID
            end if
          end if
        end tell
      else
        set previousID to -1
      end if
      delay 0.05
    end repeat
    return "FOCUS_PENDING|" & decisionTrace
    """
}

func executeRoute(_ script: String) -> String {
    var error: NSDictionary?
    let value = NSAppleScript(source: script)?.executeAndReturnError(&error).stringValue
    if let error { return "ERROR:\(error[NSAppleScript.errorNumber] ?? "unknown")" }
    return value ?? "ERROR:EMPTY_RESULT"
}


