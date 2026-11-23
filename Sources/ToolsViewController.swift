import UIKit

/// 工具页：设备信息 / 哈希编码 / 网络诊断（全部实测可用）
final class ToolsViewController: UIViewController {

    private let bg = StarfieldView()
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let inputField = UITextField()
    private let outputView = UITextView()

    private let hostField = UITextField()
    private let portField = UITextField()
    private let netResult = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        build()
    }

    private func styleCard(_ v: UIView) {
        v.backgroundColor = UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 0.85)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 0.22, green: 0.35, blue: 0.65, alpha: 0.8).cgColor
    }

    private func title(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(white: 0.72, alpha: 1)
        return l
    }

    private func card(_ content: UIView) -> UIView {
        let v = UIView()
        styleCard(v)
        content.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: v.topAnchor, constant: 14),
            content.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -14),
            content.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -14)
        ])
        return v
    }

    private func build() {
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        let head = UILabel()
        head.text = "工具"
        head.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        head.textColor = .white
        stack.addArrangedSubview(head)

        // 设备信息
        let infoStack = UIStackView()
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.addArrangedSubview(title("设备信息"))
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        infoLabel.textColor = UIColor(white: 0.88, alpha: 1)
        infoLabel.text = DeviceInfo.summary
        infoStack.addArrangedSubview(infoLabel)
        stack.addArrangedSubview(card(infoStack))

        // 哈希 / 编码
        let toolStack = UIStackView()
        toolStack.axis = .vertical
        toolStack.spacing = 10
        toolStack.addArrangedSubview(title("哈希 / 编码"))

        inputField.placeholder = "输入文本"
        inputField.textColor = .white
        inputField.font = UIFont.systemFont(ofSize: 14)
        inputField.backgroundColor = UIColor(white: 1, alpha: 0.07)
        inputField.layer.cornerRadius = 8
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        inputField.leftViewMode = .always
        inputField.heightAnchor.constraint(equalToConstant: 38).isActive = true
        toolStack.addArrangedSubview(inputField)

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 8
        for row in [["MD5", "SHA1", "SHA256"], ["Base64↑", "Base64↓", "URL↑"], ["Hex↑", "Hex↓", "二维码"]] {
            let r = UIStackView()
            r.axis = .horizontal
            r.spacing = 8
            r.distribution = .fillEqually
            for t in row {
                let b = UIButton(type: .system)
                b.setTitle(t, for: .normal)
                b.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                b.setTitleColor(.white, for: .normal)
                b.backgroundColor = UIColor(red: 0.15, green: 0.30, blue: 0.62, alpha: 0.95)
                b.layer.cornerRadius = 8
                b.heightAnchor.constraint(equalToConstant: 36).isActive = true
                b.addTarget(self, action: #selector(onTool(_:)), for: .touchUpInside)
                r.addArrangedSubview(b)
            }
            grid.addArrangedSubview(r)
        }
        toolStack.addArrangedSubview(grid)

        outputView.isEditable = false
        outputView.backgroundColor = UIColor(white: 1, alpha: 0.06)
        outputView.layer.cornerRadius = 8
        outputView.textColor = UIColor(red: 0.45, green: 0.95, blue: 0.70, alpha: 1)
        outputView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        outputView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        outputView.text = "结果区"
        toolStack.addArrangedSubview(outputView)
        stack.addArrangedSubview(card(toolStack))

        // 网络
        let netStack = UIStackView()
        netStack.axis = .vertical
        netStack.spacing = 10
        netStack.addArrangedSubview(title("网络诊断"))
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8

        func field(_ ph: String) -> UITextField {
            let f = UITextField()
            f.placeholder = ph
            f.textColor = .white
            f.font = UIFont.systemFont(ofSize: 14)
            f.backgroundColor = UIColor(white: 1, alpha: 0.07)
            f.layer.cornerRadius = 8
            f.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
            f.leftViewMode = .always
            f.heightAnchor.constraint(equalToConstant: 38).isActive = true
            return f
        }
        let hf = field("域名或 IP")
        let pf = field("端口")
        pf.widthAnchor.constraint(equalToConstant: 80).isActive = true
        pf.keyboardType = .numberPad
        row.addArrangedSubview(hf)
        row.addArrangedSubview(pf)
        netStack.addArrangedSubview(row)
        self.hostField.overrideUserInterfaceStyle = .dark
        netStack.removeArrangedSubview(row)
        // 保存引用
        self.hostField.removeFromSuperview()
        netStack.addArrangedSubview(row)
        self.hostFieldRef = hf
        self.portFieldRef = pf

        let btnRow = UIStackView()
        btnRow.axis = .horizontal
        btnRow.spacing = 8
        for (t, sel) in [("TCP 测试", #selector(onTCP)), ("DNS 解析", #selector(onDNS))] {
            let b = UIButton(type: .system)
            b.setTitle(t, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            b.setTitleColor(.white, for: .normal)
            b.backgroundColor = UIColor(red: 0.15, green: 0.30, blue: 0.62, alpha: 0.95)
            b.layer.cornerRadius = 8
            b.heightAnchor.constraint(equalToConstant: 40).isActive = true
            b.addTarget(self, action: sel, for: .touchUpInside)
            btnRow.addArrangedSubview(b)
        }
        netStack.addArrangedSubview(btnRow)

        netResult.numberOfLines = 0
        netResult.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        netResult.textColor = UIColor(red: 0.45, green: 0.95, blue: 0.70, alpha: 1)
        netResult.text = "—"
        netStack.addArrangedSubview(netResult)
        stack.addArrangedSubview(card(netStack))

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: g.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -30),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])
    }

    private var hostFieldRef: UITextField?
    private var portFieldRef: UITextField?

    // MARK: - 动作

    @objc private func onTool(_ sender: UIButton) {
        let t = (inputField.text ?? "").isEmpty ? "" : inputField.text!
        let title = sender.title(for: .normal) ?? ""
        switch title {
        case "MD5":    outputView.text = ToolBox.md5(t)
        case "SHA1":   outputView.text = ToolBox.sha1(t)
        case "SHA256": outputView.text = ToolBox.sha256(t)
        case "Base64↑": outputView.text = ToolBox.base64Encode(t)
        case "Base64↓": outputView.text = ToolBox.base64Decode(t) ?? "解码失败"
        case "URL↑":   outputView.text = ToolBox.urlEncode(t)
        case "Hex↑":   outputView.text = ToolBox.hexEncode(t)
        case "Hex↓":   outputView.text = ToolBox.hexDecode(t) ?? "解码失败"
        case "二维码":
            guard let img = ToolBox.qrImage(t, size: 220) else { outputView.text = "生成失败"; return }
            let ac = UIViewController()
            ac.view.backgroundColor = .white
            let iv = UIImageView(image: img)
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            ac.view.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: ac.view.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: ac.view.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: 260),
                iv.heightAnchor.constraint(equalToConstant: 260)
            ])
            present(ac, animated: true)
            outputView.text = "二维码已生成（点击空白关闭）"
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissQR))
            ac.view.addGestureRecognizer(tap)
        default: break
        }
    }

    @objc private func dismissQR() { dismiss(animated: true) }

    @objc private func onTCP() {
        let host = hostFieldRef?.text ?? ""
        let port = UInt16(portFieldRef?.text ?? "") ?? 443
        guard !host.isEmpty else { netResult.text = "请填 host"; return }
        netResult.text = "测试中…"
        ToolBox.tcpCheck(host: host, port: port) { ok, ms in
            self.netResult.text = ok ? "✓ \(host):\(port) 可连接  \(ms)ms"
                                     : "✗ \(host):\(port) 不可达"
        }
    }

    @objc private func onDNS() {
        let host = hostFieldRef?.text ?? ""
        guard !host.isEmpty else { netResult.text = "请填域名"; return }
        netResult.text = "解析中…"
        ToolBox.resolve(host) { ips in
            self.netResult.text = ips.isEmpty ? "解析失败" : ips.joined(separator: "\n")
        }
    }
}
