import Foundation

@main
struct ConfigurationTests {
    static func main() throws {
        for directory in ["Default", "Profile 1", "Profile 123"] {
            let config = LauncherConfiguration(profileDirectory: directory, windowTag: "工作 \\\"窗口")
            try config.validate()
            let data = try JSONEncoder().encode(config)
            let decoded = try JSONDecoder().decode(LauncherConfiguration.self, from: data)
            precondition(decoded == config)
        }
        for directory in ["", "../Default", "/tmp/Profile 1", "--incognito", "Profile 1\n", "Default\n"] {
            do { try LauncherConfiguration(profileDirectory: directory, windowTag: "WorkWindow").validate(); fatalError("accepted invalid directory") }
            catch {}
        }
        for tag in ["", "  ", "a\nb", "a\u{0}b", String(repeating: "a", count: 81)] {
            do { try LauncherConfiguration(profileDirectory: "Default", windowTag: tag).validate(); fatalError("accepted invalid tag") }
            catch {}
        }
        precondition(appleScriptString("a\"b\\c") == "\"a\\\"b\\\\c\"")
        print("PASS configuration validation, JSON round trip, AppleScript escaping")
    }
}
