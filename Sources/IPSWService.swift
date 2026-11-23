import Foundation

struct Firmware {
    let version: String
    let build: String
    let url: String
    let size: Int64
    let released: String
    var downloadURL: URL? { URL(string: url) }
}

final class IPSWService {

    static let shared = IPSWService()

    /// 查设备的固件列表（ipsw.me 公开 API）
    func fetchFirmwares(deviceId: String, completion: @escaping ([Firmware]) -> Void) {
        guard let url = URL(string: "https://api.ipsw.me/v4/device/\(deviceId)?type=ipsw") else {
            completion([])
            return
        }
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 25
        cfg.timeoutIntervalForResource = 60
        let session = URLSession(configuration: cfg)

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("SpaceX/1.1", forHTTPHeaderField: "User-Agent")

        session.dataTask(with: req) { data, _, _ in
            var list: [Firmware] = []
            if let data = data,
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let fws = obj["firmwares"] as? [[String: Any]] {
                for f in fws {
                    guard let v = f["version"] as? String,
                          let b = f["buildid"] as? String,
                          let u = f["url"] as? String else { continue }
                    let size = (f["filesize"] as? NSNumber)?.int64Value ?? 0
                    let rel = f["releasedate"] as? String ?? ""
                    list.append(Firmware(version: v, build: b, url: u, size: size, released: rel))
                }
            }
            DispatchQueue.main.async { completion(list) }
        }.resume()
    }

    /// 下载文件到 App 沙盒
    func download(_ firmware: Firmware,
                  progress: @escaping (Double) -> Void,
                  completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = firmware.downloadURL else {
            completion(.failure(NSError(domain: "ipsw", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "无效链接"])))
            return
        }
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 3600
        let session = URLSession(configuration: cfg)

        session.downloadTask(with: url) { tmp, resp, err in
            DispatchQueue.main.async {
                if let err = err { completion(.failure(err)); return }
                guard let tmp = tmp else {
                    completion(.failure(NSError(domain: "ipsw", code: -2,
                                                userInfo: [NSLocalizedDescriptionKey: "下载失败"])))
                    return
                }
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let name = "\(firmware.version)_\(firmware.build)_\(url.lastPathComponent)"
                let dst = docs.appendingPathComponent(name)
                try? FileManager.default.removeItem(at: dst)
                do {
                    try FileManager.default.moveItem(at: tmp, to: dst)
                    completion(.success(dst))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
