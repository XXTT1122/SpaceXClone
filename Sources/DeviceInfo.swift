import Foundation
import UIKit
import MachO

/// 设备信息采集（全部为公开 API，自签可用）
struct DeviceInfo {

    static var machineId: String {
        var info = utsname()
        uname(&info)
        return withUnsafeBytes(of: &info.machine) { raw in
            String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
        }
    }

    static var marketingName: String {
        let map: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",  "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini","iPhone14,5": "iPhone 13",
            "iPhone14,6": "iPhone SE 3",   "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus","iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max","iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus","iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max","iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max","iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus","iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max","iPhone11,6": "iPhone XS Max",
            "iPhone11,8": "iPhone XR",   "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro","iPhone12,5": "iPhone 11 Pro Max",
            "iPhone13,1": "iPhone 12 mini","iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro","iPhone13,4": "iPhone 12 Pro Max",
            "iPad13,4": "iPad Pro 11 (M1)","iPad14,3": "iPad Pro 11 (M2)"
        ]
        return map[machineId] ?? machineId
    }

    static var systemVersion: String { UIDevice.current.systemVersion }
    static var systemName: String { UIDevice.current.systemName }
    static var deviceName: String { UIDevice.current.name }

    static var totalMemory: String {
        String(format: "%.1f GB", Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024)
    }

    static var diskFree: String {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let free = attrs[.systemFreeSize] as? Int64 else { return "-" }
        return String(format: "%.1f GB 可用", Double(free) / 1024 / 1024 / 1024)
    }

    static var batteryLevel: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let lvl = UIDevice.current.batteryLevel
        return lvl < 0 ? "未知" : String(format: "%.0f%%", lvl * 100)
    }

    static var screen: String {
        let b = UIScreen.main.bounds
        let s = UIScreen.main.scale
        return String(format: "%.0f × %.0f @%.0fx", b.width, b.height, s)
    }

    static var identifierForVendor: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "-"
    }

    static var cpuArch: String {
        #if arch(arm64e)
        return "arm64e"
        #elseif arch(arm64)
        return "arm64"
        #else
        return "unknown"
        #endif
    }

    static var jailbroken: Bool {
        let paths = ["/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib",
                     "/bin/bash", "/usr/sbin/sshd", "/etc/apt", "/private/jailbreak.txt"]
        for p in paths where FileManager.default.fileExists(atPath: p) { return true }
        if let s = try? String(contentsOfFile: "/etc/hosts"), s.contains("cydia") { return true }
        return false
    }

    /// 完整信息文本
    static var summary: String {
        """
        机型        \(marketingName)
        标识符      \(machineId)
        系统        \(systemName) \(systemVersion)
        架构        \(cpuArch)
        内存        \(totalMemory)
        存储        \(diskFree)
        电量        \(batteryLevel)
        屏幕        \(screen)
        越狱        \(jailbroken ? "已越狱" : "未越狱")
        IDFV        \(identifierForVendor)
        """
    }
}
