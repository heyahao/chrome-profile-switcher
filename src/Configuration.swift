import Foundation

struct LauncherConfiguration: Codable, Equatable {
    let profileDirectory: String
    let windowTag: String

    func validate() throws {
        // A directory name, never an arbitrary path or command-line argument.
        guard profileDirectory.range(of: #"\A(Default|Profile [0-9]+)\z"#, options: .regularExpression) != nil else {
            throw ConfigurationError.invalidDirectory
        }
        guard !windowTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              windowTag.count <= 80,
              windowTag.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }) else {
            throw ConfigurationError.invalidTag
        }
    }
}

enum ConfigurationError: LocalizedError {
    case invalidDirectory, invalidTag
    var errorDescription: String? {
        switch self {
        case .invalidDirectory: return "资料目录应为 Default 或 Profile 1 这样的名称，请从 chrome://version 复制最后一段。"
        case .invalidTag: return "窗口名称不能为空，最多 80 个字符，不能含换行等控制字符。"
        }
    }
}

// Escape user input as an AppleScript string literal, not as executable code.
func appleScriptString(_ value: String) -> String {
    "\"" + value.replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"") + "\""
}
