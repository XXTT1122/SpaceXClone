import Foundation
import CommonCrypto

/// 工具扩展：JSON 格式化 / 时间戳 / 随机密码 / 设备标识
enum ToolBoxExtras {

    /// JSON 格式化（美化）
    static func jsonPretty(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj,
                                                       options: [.prettyPrinted, .sortedKeys]),
              let out = String(data: pretty, encoding: .utf8) else {
            return "❌ 不是合法 JSON"
        }
        return out
    }

    /// JSON 压缩
    static func jsonMinify(_ s: String) -> String {
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let mini = try? JSONSerialization.data(withJSONObject: obj),
              let out = String(data: mini, encoding: .utf8) else {
            return "❌ 不是合法 JSON"
        }
        return out
    }

    /// 时间戳 → 日期（自动判断秒/毫秒）
    static func timestampToDate(_ s: String) -> String {
        let clean = s.trimmingCharacters(in: .whitespaces)
        guard let v = Double(clean) else { return "❌ 不是数字" }
        let sec = v > 1e11 ? v / 1000.0 : v
        let d = Date(timeIntervalSince1970: sec)
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone.current
        return f.string(from: d)
    }

    /// 日期 → 时间戳
    static func dateToTimestamp(_ s: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone.current
        guard let d = f.date(from: s.trimmingCharacters(in: .whitespaces)) else {
            // 试仅日期
            f.dateFormat = "yyyy-MM-dd"
            guard let d2 = f.date(from: s.trimmingCharacters(in: .whitespaces)) else {
                return "❌ 格式应为 yyyy-MM-dd HH:mm:ss"
            }
            return "\(Int(d2.timeIntervalSince1970))"
        }
        return "\(Int(d.timeIntervalSince1970))"
    }

    /// 当前时间戳
    static var nowTimestamp: String {
        let sec = Int(Date().timeIntervalSince1970)
        let ms = Int(Date().timeIntervalSince1970 * 1000)
        return "秒: \(sec)\n毫秒: \(ms)"
    }

    /// 随机密码
    static func randomPassword(length: Int = 16, useSymbols: Bool = true) -> String {
        var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        if useSymbols { chars += "!@#$%^&*()-_=+[]{}<>?" }
        return String((0..<max(4, length)).map { _ in chars.randomElement()! })
    }

    /// 随机 UUID
    static var randomUUID: String { UUID().uuidString }

    /// 文件大小格式化
    static func sizeText(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var v = Double(bytes)
        var i = 0
        while v >= 1024 && i < units.count - 1 { v /= 1024; i += 1 }
        return String(format: "%.1f %@", v, units[i])
    }
}
