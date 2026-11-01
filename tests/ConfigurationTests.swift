import Foundation

@main
struct ConfigurationTests {
    static func main() throws {
        for directory in ["Default", "Profile 1", "Profile 123"] {
            let config = LauncherConfiguration(profileDirectory: directory, profileMenuName: "Work \\\"Personal")
            try config.validate()
            let data = try JSONEncoder().encode(config)
            let decoded = try JSONDecoder().decode(LauncherConfiguration.self, from: data)
            precondition(decoded == config)
            let json = try JSONSerialization.jsonObject(with: data) as! [String: String]
            precondition(json["profileMenuName"] == config.profileMenuName && json["windowTag"] == nil)
        }
        for directory in ["", "../Default", "Profile/1", "--incognito", "Profile 1\n", "Default\n"] {
            do { try LauncherConfiguration(profileDirectory: directory, profileMenuName: "Work").validate(); fatalError("accepted invalid directory") }
            catch {}
        }
        for name in ["", "  ", "a\nb", "a\u{0}b", "a\tb", String(repeating: "a", count: 81)] {
            do { try LauncherConfiguration(profileDirectory: "Default", profileMenuName: name).validate(); fatalError("accepted invalid profile menu name") }
            catch {}
        }
        let exactName = LauncherConfiguration(profileDirectory: "Default", profileMenuName: " Work ")
        try exactName.validate()
        let exactNameDecoded = try JSONDecoder().decode(LauncherConfiguration.self, from: JSONEncoder().encode(exactName))
        precondition(exactNameDecoded == exactName)

        let legacy = Data(#"{"profileDirectory":"Profile 2","windowTag":"Work"}"#.utf8)
        do {
            _ = try JSONDecoder().decode(LauncherConfiguration.self, from: legacy)
            fatalError("silently accepted legacy configuration")
        } catch ConfigurationError.migrationRequired {
            precondition(ConfigurationError.migrationRequired.localizedDescription.contains("重新设置"))
        }
        precondition(LauncherConfiguration.legacyProfileDirectory(from: legacy) == "Profile 2")
        let invalidLegacy = Data(#"{"profileDirectory":"../Default","windowTag":"Personal"}"#.utf8)
        precondition(LauncherConfiguration.legacyProfileDirectory(from: invalidLegacy) == nil)
        let modern = try JSONEncoder().encode(exactName)
        precondition(LauncherConfiguration.legacyProfileDirectory(from: modern) == nil)
        precondition(LauncherConfiguration.legacyProfileDirectory(from: Data("invalid JSON".utf8)) == nil)
        let mixed = Data(#"{"profileDirectory":"Default","windowTag":"Work","profileMenuName":"Personal"}"#.utf8)
        do {
            _ = try JSONDecoder().decode(LauncherConfiguration.self, from: mixed)
            fatalError("accepted ambiguous legacy configuration")
        } catch ConfigurationError.migrationRequired {}
        precondition(appleScriptString("a\"b\\c") == "\"a\\\"b\\\\c\"")
        print("PASS configuration validation, JSON round trip, legacy migration, AppleScript escaping")
    }
}
