import UIKit

/// 设置页：所有持久化配置 + 重置 + 关于
final class SettingsViewController: UIViewController {

    private let bg = StarfieldView()
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        build()
    }

    private func card(_ inner: UIStackView) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 0.85)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 0.22, green: 0.35, blue: 0.65, alpha: 0.8).cgColor
        inner.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: v.topAnchor, constant: 14),
            inner.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -14),
            inner.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 14),
            inner.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -14)
        ])
        return v
    }

    private func title(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(white: 0.72, alpha: 1)
        return l
    }

    private func row(_ label: String, _ value: String) -> UIStackView {
        let r = UIStackView()
        r.axis = .horizontal
        let l = UILabel()
        l.text = label
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor(white: 0.88, alpha: 1)
        let v = UILabel()
        v.text = value
        v.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        v.textColor = UIColor(red: 0.45, green: 0.95, blue: 0.70, alpha: 1)
        v.textAlignment = .right
        r.addArrangedSubview(l)
        r.addArrangedSubview(v)
        return r
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
        head.text = "设置"
        head.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        head.textColor = .white
        stack.addArrangedSubview(head)

        // 服务器配置（只读展示）
        let srv = UIStackView()
        srv.axis = .vertical
        srv.spacing = 8
        srv.addArrangedSubview(title("授权服务器"))
        srv.addArrangedSubview(row("地址", "192.168.1.112"))
        srv.addArrangedSubview(row("端口", "443 (HTTPS)"))
        srv.addArrangedSubview(row("app_key", "ak_opus_card_…"))
        stack.addArrangedSubview(card(srv))

        // 当前配置
        let cfg = UIStackView()
        cfg.axis = .vertical
        cfg.spacing = 8
        cfg.addArrangedSubview(title("当前配置"))
        let hue = UserDefaults.standard.double(forKey: "ax.hue")
        let sat = UserDefaults.standard.double(forKey: "ax.sat")
        let bri = UserDefaults.standard.double(forKey: "ax.bri")
        cfg.addArrangedSubview(row("色相", String(format: "%.2f", hue == 0 ? 0.58 : hue)))
        cfg.addArrangedSubview(row("饱和度", String(format: "%.2f", sat == 0 ? 0.8 : sat)))
        cfg.addArrangedSubview(row("亮度", String(format: "%.2f", bri == 0 ? 1.0 : bri)))
        cfg.addArrangedSubview(row("过直播", UserDefaults.standard.bool(forKey: "ax.passlive") ? "开" : "关"))
        let anti = UserDefaults.standard.object(forKey: "ax.antishot") == nil
            ? true : UserDefaults.standard.bool(forKey: "ax.antishot")
        cfg.addArrangedSubview(row("防截屏", anti ? "开" : "关"))
        stack.addArrangedSubview(card(cfg))

        // 设备
        let dev = UIStackView()
        dev.axis = .vertical
        dev.spacing = 8
        dev.addArrangedSubview(title("设备"))
        dev.addArrangedSubview(row("机型", DeviceInfo.marketingName))
        dev.addArrangedSubview(row("标识", DeviceInfo.machineId))
        dev.addArrangedSubview(row("系统", "iOS \(DeviceInfo.systemVersion)"))
        dev.addArrangedSubview(row("芯片架构", DeviceInfo.cpuArch))
        stack.addArrangedSubview(card(dev))

        // 操作
        let reset = UIButton(type: .system)
        reset.setTitle("重置所有设置", for: .normal)
        reset.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        reset.setTitleColor(.white, for: .normal)
        reset.backgroundColor = UIColor(red: 0.45, green: 0.20, blue: 0.22, alpha: 0.95)
        reset.layer.cornerRadius = 11
        reset.heightAnchor.constraint(equalToConstant: 46).isActive = true
        reset.addTarget(self, action: #selector(onReset), for: .touchUpInside)
        stack.addArrangedSubview(reset)

        let clearFiles = UIButton(type: .system)
        clearFiles.setTitle("清空已下载文件", for: .normal)
        clearFiles.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        clearFiles.setTitleColor(.white, for: .normal)
        clearFiles.backgroundColor = UIColor(red: 0.35, green: 0.25, blue: 0.20, alpha: 0.95)
        clearFiles.layer.cornerRadius = 11
        clearFiles.heightAnchor.constraint(equalToConstant: 46).isActive = true
        clearFiles.addTarget(self, action: #selector(onClearFiles), for: .touchUpInside)
        stack.addArrangedSubview(clearFiles)

        let close = UIButton(type: .system)
        close.setTitle("返回", for: .normal)
        close.setTitleColor(.white, for: .normal)
        close.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        close.backgroundColor = UIColor(white: 1, alpha: 0.10)
        close.layer.cornerRadius = 11
        close.heightAnchor.constraint(equalToConstant: 46).isActive = true
        close.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        stack.addArrangedSubview(close)

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

    @objc private func onReset() {
        let ac = UIAlertController(title: "重置设置", message: "所有主题和开关将恢复默认值", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        ac.addAction(UIAlertAction(title: "重置", style: .destructive) { _ in
            ["ax.hue", "ax.sat", "ax.bri", "ax.passlive", "ax.antishot"].forEach {
                UserDefaults.standard.removeObject(forKey: $0)
            }
            self.toast("已重置")
        })
        present(ac, animated: true)
    }

    @objc private func onClearFiles() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let files = (try? FileManager.default.contentsOfDirectory(at: docs,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: .skipsHiddenFiles)) ?? []
        let ac = UIAlertController(title: "清空文件", message: "将删除 \(files.count) 个已下载文件", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        ac.addAction(UIAlertAction(title: "删除", style: .destructive) { _ in
            var n = 0
            for f in files {
                if (try? FileManager.default.removeItem(at: f)) != nil { n += 1 }
            }
            self.toast("已删除 \(n) 个文件")
        })
        present(ac, animated: true)
    }

    @objc private func onClose() { dismiss(animated: true) }

    private func toast(_ m: String) {
        let a = UIAlertController(title: nil, message: m, preferredStyle: .alert)
        present(a, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { a.dismiss(animated: true) }
    }
}
