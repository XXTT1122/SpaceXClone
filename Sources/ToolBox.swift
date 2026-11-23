import Foundation
import CryptoKit
import CoreImage
import UIKit

/// 本地工具集：哈希 / 编码 / 二维码（全部离线可用）
enum ToolBox {

    // MARK: - 哈希

    static func md5(_ s: String) -> String {
        let data = Data(s.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func sha1(_ s: String) -> String {
        let data = Data(s.utf8)
        let digest = Insecure.SHA1.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func sha256(_ s: String) -> String {
        let data = Data(s.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - 编码

    static func base64Encode(_ s: String) -> String {
        Data(s.utf8).base64EncodedString()
    }

    static func base64Decode(_ s: String) -> String? {
        guard let d = Data(base64Encoded: s.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        return String(data: d, encoding: .utf8)
    }

    static func urlEncode(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
    }

    static func urlDecode(_ s: String) -> String {
        s.removingPercentEncoding ?? s
    }

    static func hexEncode(_ s: String) -> String {
        s.utf8.map { String(format: "%02x", $0) }.joined()
    }

    static func hexDecode(_ s: String) -> String? {
        let clean = s.replacingOccurrences(of: " ", with: "")
        guard clean.count % 2 == 0 else { return nil }
        var bytes: [UInt8] = []
        var idx = clean.startIndex
        while idx < clean.endIndex {
            let next = clean.index(idx, offsetBy: 2)
            guard let b = UInt8(clean[idx..<next], radix: 16) else { return nil }
            bytes.append(b)
            idx = next
        }
        return String(bytes: bytes, encoding: .utf8)
    }

    // MARK: - 二维码

    static func qrImage(_ text: String, size: CGFloat = 240) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(Data(text.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let out = filter.outputImage else { return nil }
        let scale = size / out.extent.width
        let scaled = out.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let ctx = CIContext()
        guard let cg = ctx.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    // MARK: - 网络

    /// TCP 连通性测试（自签可用，纯 socket）
    static func tcpCheck(host: String, port: UInt16, timeout: TimeInterval = 3.0,
                         completion: @escaping (Bool, Int) -> Void) {
        DispatchQueue.global().async {
            let start = Date()
            var hints = addrinfo(ai_flags: 0, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM,
                                 ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil,
                                 ai_addr: nil, ai_next: nil)
            var res: UnsafeMutablePointer<addrinfo>?
            let gai = getaddrinfo(host, String(port), &hints, &res)
            guard gai == 0, let info = res else {
                DispatchQueue.main.async { completion(false, 0) }
                return
            }
            defer { freeaddrinfo(res) }

            let fd = socket(info.pointee.ai_family, info.pointee.ai_socktype, info.pointee.ai_protocol)
            guard fd >= 0 else {
                DispatchQueue.main.async { completion(false, 0) }
                return
            }
            defer { close(fd) }

            // 设置超时
            var tv = timeval(tv_sec: Int(timeout), tv_usec: 0)
            setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))

            let r = connect(fd, info.pointee.ai_addr, info.pointee.ai_addrlen)
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            DispatchQueue.main.async { completion(r == 0, ms) }
        }
    }

    /// DNS 解析（getaddrinfo，纯系统调用）
    static func resolve(_ host: String, completion: @escaping ([String]) -> Void) {
        DispatchQueue.global().async {
            var hints = addrinfo(ai_flags: 0, ai_family: AF_INET, ai_socktype: SOCK_STREAM,
                                 ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil,
                                 ai_addr: nil, ai_next: nil)
            var res: UnsafeMutablePointer<addrinfo>?
            guard getaddrinfo(host, nil, &hints, &res) == 0, let first = res else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            defer { freeaddrinfo(res) }
            var ips: [String] = []
            var cur: UnsafeMutablePointer<addrinfo>? = first
            while let c = cur {
                if let sa = c.pointee.ai_addr {
                    var buf = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(sa, c.pointee.ai_addrlen, &buf, socklen_t(buf.count),
                                   nil, 0, NI_NUMERICHOST) == 0 {
                        let ip = String(cString: buf)
                        if !ips.contains(ip) { ips.append(ip) }
                    }
                }
                cur = c.pointee.ai_next
            }
            DispatchQueue.main.async { completion(ips) }
        }
    }
}
