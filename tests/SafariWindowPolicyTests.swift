// 不操作用户窗口的决策回归；与生产代码编译同一份 SafariWindowPolicy。
import Foundation

@main
struct SafariWindowPolicyTests {
    static func main() {
        func state(_ id: String = "A", main: Bool = false, min: Bool = false,
                   full: Bool = false, standard: Bool = true) -> SafariWindowState {
            SafariWindowState(identifier: id, isMain: main, isMinimized: min,
                isFullScreen: full, isStandard: standard)
        }
        var passed = 0
        func check(_ name: String, _ windows: [SafariWindowState], front: Bool = false,
                   reliable: Bool = true, remembered: String? = nil, expected: SafariWindowAction) {
            let result = safariWindowAction(windows: windows, wasFrontmost: front,
                windowListReliable: reliable, minimizedByLauncher: remembered)
            guard result == expected else { fatalError("\(name): \(result) != \(expected)") }
            passed += 1; print("PASS \(name)")
        }
        check("background existing", [state(main: true)], expected: .focus(0))
        check("foreground toggle", [state(main: true)], front: true, expected: .minimize(0))
        check("restore minimized", [state(min: true)], expected: .focus(0))
        check("remembered wins over remaining main", [state(main: true), state("B", min: true)],
              front: true, remembered: "B", expected: .focus(1))
        check("closed remembered window", [state(main: true)], front: true,
              remembered: "closed", expected: .minimize(0))
        check("cross Space not front", [state(main: true)], expected: .focus(0))
        check("full screen never minimize", [state(main: true, full: true)], front: true, expected: .focus(0))
        check("dialog does not minimize", [state(main: true, standard: false)], front: true, expected: .focus(0))
        check("ignore stray dialog before main", [state(standard: false), state("B", main: true)],
              front: true, expected: .minimize(1))
        check("all windows minimized", [state(min: true), state("B", min: true)], expected: .focus(0))
        check("manually minimized Safari reports AXDialog", [state(min: true, standard: false)], expected: .focus(0))
        check("no windows", [], expected: .reopen)
        check("AX failure is not no windows", [], reliable: false, expected: .activate)
        check("only non-main dialog", [state(standard: false)], expected: .activate)
        print("Safari policy: \(passed) passed")
    }
}
