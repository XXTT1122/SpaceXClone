import Foundation
import Security

struct CardResult {
    let ok: Bool
    let status: String      // ok / invalid / expired / error
    let expireDate: String?
    let message: String
}

final class CardService: NSObject, URLSessionDelegate {

    static let shared = CardService()

    // 你的 AX 公钥（360 字符，直接内置）
    private let pubKeyB64 = "MIIBCgKCAQEAyk3Zb23CPHzzkHaVN0cn4TJoKR34IuYTbyiRGDBUYeksYYHbZI93E/ziIUJaXylFA4ISB+jjy/I/GUv9ShgFBLz8un4R0kxTVhVV3byrbr+gPYTOnz/aOffmNYLU1bAatG0joEn7TZ35Nyi0zR6tSlaPJEpgEmMXR3nD+lujxinKbAN1CV0wC3AlyPx3oelrm6T5Nk7S+LOFSxnbavi7mx2uJ8FjQBHF+0XFhaboSyPTZZOx+YAxEeOms+LXN+gyKjBR01P5/Wa6ckIUMqslPwCrVxoMis3zpH5Gs+hXhF0F3NTRK4DwGd1TqK7y1E3S/nbEIRE+SdhZ6Ndoe67PPQIDAQAB"

    // 你的授权服务器（局域网 IP 或以后换成域名）
    private let host = "192.168.1.112"
    private let appKey = "ak_opus_card_152_20261101"

    // 自签场景：接受服务器证书（不固定）
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func activate(cardCode: String, completion: @escaping (CardResult) -> Void) {
        let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        guard let url = URL(string: "https://\(host)/api/v1/client/probe?app_key=\(appKey)&nonce=\(nonce)") else {
            completion(CardResult(ok: false, status: "error", expireDate: nil, message: "URL 无效"))
            return
        }

        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 10
        cfg.timeoutIntervalForResource = 15
        let session = URLSession(configuration: cfg, delegate: self, delegateQueue: nil)

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("SpaceX/1.1", forHTTPHeaderField: "User-Agent")

        session.dataTask(with: req) { [weak self] data, resp, err in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let err = err {
                    completion(CardResult(ok: false, status: "error", expireDate: nil,
                                          message: "网络错误：\(err.localizedDescription)"))
                    return
                }
                guard let data = data,
                      let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    completion(CardResult(ok: false, status: "error", expireDate: nil, message: "响应解析失败"))
                    return
                }

                let payload   = obj["payload"] as? String ?? ""
                let sigB64    = obj["signature"] as? String ?? ""
                let nonceBack = obj["nonce"] as? String ?? nonce

                let sigOK = self.verify(payload: payload, signatureB64: sigB64, nonce: nonceBack)

                var status = "invalid"
                var expireDate: String? = nil
                if let pd = payload.data(using: .utf8),
                   let po = try? JSONSerialization.jsonObject(with: pd) as? [String: Any] {
                    if let s = po["status"] as? String { status = s }
                    if let e = po["expire_date"] as? String, e != "permanent" { expireDate = e }
                }

                if !sigOK {
                    completion(CardResult(ok: false, status: "error", expireDate: nil, message: "签名验证失败"))
                    return
                }

                switch status {
                case "ok", "valid":
                    let d = expireDate ?? "永久"
                    completion(CardResult(ok: true, status: "ok", expireDate: expireDate,
                                          message: "激活成功 · 到期 \(d)"))
                case "expired":
                    completion(CardResult(ok: false, status: "expired", expireDate: expireDate, message: "卡密已过期"))
                default:
                    completion(CardResult(ok: false, status: "invalid", expireDate: nil, message: "卡密无效"))
                }
            }
        }.resume()
    }

    // RSA-PSS-SHA256 验签：签名对象是 "KVRESP-V1\n<nonce>\n<payload>"
    private func verify(payload: String, signatureB64: String, nonce: String) -> Bool {
        guard let derData = Data(base64Encoded: pubKeyB64),
              let sigData = Data(base64Encoded: signatureB64) else { return false }

        let attrs: [CFString: Any] = [
            kSecAttrKeyType:  kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 2048
        ]
        var err: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(derData as CFData, attrs as CFDictionary, &err) else {
            return false
        }
        let msg = "KVRESP-V1\n\(nonce)\n\(payload)"
        guard let msgData = msg.data(using: .utf8) else { return false }

        return SecKeyVerifySignature(key,
                                     .rsaSignatureMessagePSSSHA256,
                                     msgData as CFData,
                                     sigData as CFData,
                                     &err)
    }
}
