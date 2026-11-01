import Foundation

struct LauncherConfiguration: Codable, Equatable {
    let profileDirectory: String
    let profileMenuName: String

    private enum CodingKeys: String, CodingKey {
        case profileDirectory, profileMenuName, windowTag
    }

    init(profileDirectory: String, profileMenuName: String) {
        self.profileDirectory = profileDirectory
        self.profileMenuName = profileMenuName
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard !values.contains(.windowTag) else { throw ConfigurationError.migrationRequired }
        profileDirectory = try values.decode(String.self, forKey: .profileDirectory)
        profileMenuName = try values.decode(String.self, forKey: .profileMenuName)
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(profileDirectory, forKey: .profileDirectory)
        try values.encode(profileMenuName, forKey: .profileMenuName)
    }

    // Recover only the directory for setup; a legacy window tag is never a profile name.
    static func legacyProfileDirectory(from data: Data) -> String? {
        struct LegacyConfiguration: Decodable {
            let profileDirectory: String
            let windowTag: String
        }
        guard let legacy = try? JSONDecoder().decode(LegacyConfiguration.self, from: data),
              validDirectory(legacy.profileDirectory) else { return nil }
        return legacy.profileDirectory
    }

    private static func validDirectory(_ value: String) -> Bool {
        value.range(of: #"\A(Default|Profile [0-9]+)\z"#, options: .regularExpression) != nil
    }

    func validate() throws {
        // A directory name, never an arbitrary path or command-line argument.
        guard Self.validDirectory(profileDirectory) else {
            throw ConfigurationError.invalidDirectory
        }
        guard !profileMenuName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              profileMenuName.count <= 80,
              profileMenuName.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }) else {
            throw ConfigurationError.invalidProfileMenuName
        }
    }
}

enum ConfigurationError: LocalizedError {
    case invalidDirectory, invalidProfileMenuName, migrationRequired
    var errorDescription: String? {
        switch self {
        case .invalidDirectory: return "资料目录应为 Default 或 Profile 1 这样的名称，请从 chrome://version 复制最后一段。"
        case .invalidProfileMenuName: return "个人资料菜单名称不能为空，最多 80 个字符，不能含换行等控制字符。"
        case .migrationRequired: return "旧版配置使用窗口名称，需要重新设置。请从 Chrome 顶部“个人资料 / Profiles”菜单复制目标资料的精确显示名称；旧窗口名称不能作为资料名称。取消设置会保留旧配置。"
        }
    }
}

// Escape user input as an AppleScript string literal, not as executable code.
func appleScriptString(_ value: String) -> String {
    "\"" + value.replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"") + "\""
}
