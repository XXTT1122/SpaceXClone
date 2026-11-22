import UIKit

final class ActivationViewController: UIViewController, UITextFieldDelegate {

    // MARK: - 视图

    private let bg = StarfieldView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "SpaceX"
        l.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let versionLabel: UILabel = {
        let l = UILabel()
        l.text = "VERSION 1.1"
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor(white: 0.65, alpha: 1)
        return l
    }()

    private let themeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("☾", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0.25, green: 0.20, blue: 0.55, alpha: 0.85)
        b.layer.cornerRadius = 22
        return b
    }()

    private let deviceCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.05, green: 0.22, blue: 0.18, alpha: 0.75)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.2
        v.layer.borderColor = UIColor(red: 0.20, green: 0.85, blue: 0.55, alpha: 0.85).cgColor
        return v
    }()

    private let deviceCardTitle: UILabel = {
        let l = UILabel()
        l.text = "设备与系统支持"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor(white: 0.90, alpha: 1)
        return l
    }()

    private let deviceCardState: UILabel = {
        let l = UILabel()
        l.text = "✓ 当前环境支持"
        l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(red: 0.35, green: 0.95, blue: 0.65, alpha: 1)
        return l
    }()

    private let deviceCardDetail: UILabel = {
        let l = UILabel()
        l.text = "iPhone · iOS"
        l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(red: 0.35, green: 0.95, blue: 0.65, alpha: 1)
        return l
    }()

    private let inputField: UITextField = {
        let f = UITextField()
        f.placeholder = "请输入卡密"
        f.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        f.textColor = .white
        f.backgroundColor = UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 0.85)
        f.layer.cornerRadius = 14
        f.layer.borderWidth = 1.2
        f.layer.borderColor = UIColor(red: 0.25, green: 0.40, blue: 0.75, alpha: 0.9).cgColor
        f.textAlignment = .left
        f.autocapitalizationType = .allCharacters
        f.autocorrectionType = .no
        f.returnKeyType = .done
        f.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        f.leftViewMode = .always
        return f
    }()

    private let activateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("✓  卡密激活", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        b.setTitleColor(UIColor(red: 0.10, green: 0.18, blue: 0.35, alpha: 1), for: .normal)
        b.backgroundColor = UIColor(white: 0.97, alpha: 1)
        b.layer.cornerRadius = 16
        return b
    }()

    private let statusCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 0.85)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.0
        v.layer.borderColor = UIColor(red: 0.22, green: 0.35, blue: 0.65, alpha: 0.8).cgColor
        return v
    }()

    private let statusTitle: UILabel = {
        let l = UILabel()
        l.text = "当前状态"
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(white: 0.70, alpha: 1)
        return l
    }()

    private let statusValue: UILabel = {
        let l = UILabel()
        l.text = "等待卡密激活"
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        updateDeviceInfo()
        inputField.delegate = self
        activateButton.addTarget(self, action: #selector(onActivate), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(onTheme), for: .touchUpInside)
    }

    // MARK: - 布局

    private func setupUI() {
        [bg, titleLabel, versionLabel, themeButton, deviceCard,
         inputField, activateButton, statusCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [deviceCardTitle, deviceCardState, deviceCardDetail].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            deviceCard.addSubview($0)
        }
        [statusTitle, statusValue].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            statusCard.addSubview($0)
        }

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 56),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),

            versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            versionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            themeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            themeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            themeButton.widthAnchor.constraint(equalToConstant: 44),
            themeButton.heightAnchor.constraint(equalToConstant: 44),

            deviceCard.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 22),
            deviceCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            deviceCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            deviceCard.heightAnchor.constraint(equalToConstant: 92),

            deviceCardTitle.topAnchor.constraint(equalTo: deviceCard.topAnchor, constant: 14),
            deviceCardTitle.leadingAnchor.constraint(equalTo: deviceCard.leadingAnchor, constant: 16),

            deviceCardState.topAnchor.constraint(equalTo: deviceCardTitle.bottomAnchor, constant: 6),
            deviceCardState.leadingAnchor.constraint(equalTo: deviceCardTitle.leadingAnchor),

            deviceCardDetail.topAnchor.constraint(equalTo: deviceCardState.bottomAnchor, constant: 2),
            deviceCardDetail.leadingAnchor.constraint(equalTo: deviceCardTitle.leadingAnchor),

            inputField.topAnchor.constraint(equalTo: deviceCard.bottomAnchor, constant: 18),
            inputField.leadingAnchor.constraint(equalTo: deviceCard.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: deviceCard.trailingAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 52),

            activateButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 14),
            activateButton.leadingAnchor.constraint(equalTo: deviceCard.leadingAnchor),
            activateButton.trailingAnchor.constraint(equalTo: deviceCard.trailingAnchor),
            activateButton.heightAnchor.constraint(equalToConstant: 56),

            statusCard.topAnchor.constraint(equalTo: activateButton.bottomAnchor, constant: 18),
            statusCard.leadingAnchor.constraint(equalTo: deviceCard.leadingAnchor),
            statusCard.trailingAnchor.constraint(equalTo: deviceCard.trailingAnchor),
            statusCard.heightAnchor.constraint(equalToConstant: 66),

            statusTitle.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 12),
            statusTitle.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 16),

            statusValue.topAnchor.constraint(equalTo: statusTitle.bottomAnchor, constant: 4),
            statusValue.leadingAnchor.constraint(equalTo: statusTitle.leadingAnchor)
        ])
    }

    // MARK: - 设备信息

    private func updateDeviceInfo() {
        let name = UIDevice.current.model          // "iPhone" / "iPad"
        let sys = UIDevice.current.systemVersion   // "17.5.1"
        let pretty = Self.marketingName() ?? name
        deviceCardDetail.text = "\(pretty) · iOS \(sys)"
    }

    private static func marketingName() -> String? {
        var info = utsname()
        guard uname(&info) == 0 else { return nil }
        let id = withUnsafeBytes(of: &info.machine) { raw -> String in
            let bytes = raw.prefix { $0 != 0 }
            return String(decoding: bytes, as: UTF8.self)
        }
        let map: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,6": "iPhone SE (3rd)",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone11,8": "iPhone XR",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max"
        ]
        return map[id] ?? id
    }

    // MARK: - 交互

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func onTheme() {
        // 主题切换占位（后续接星空配色）
        let alert = UIAlertController(title: "主题设置", message: "主题切换开发中", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }

    @objc private func onActivate() {
        let code = (inputField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            setStatus("请先输入卡密", color: .systemOrange)
            return
        }
        inputField.resignFirstResponder()
        activateButton.isEnabled = false
        activateButton.alpha = 0.6
        setStatus("正在验证…", color: .white)

        CardService.shared.activate(cardCode: code) { [weak self] result in
            guard let self = self else { return }
            self.activateButton.isEnabled = true
            self.activateButton.alpha = 1.0
            if result.ok {
                self.setStatus(result.message, color: UIColor(red: 0.35, green: 0.95, blue: 0.65, alpha: 1))
                self.showActivated()
            } else {
                let color: UIColor = (result.status == "expired") ? .systemOrange : .systemRed
                self.setStatus(result.message, color: color)
            }
        }
    }

    private func setStatus(_ text: String, color: UIColor) {
        statusValue.text = text
        statusValue.textColor = color
    }

    private func showActivated() {
        let alert = UIAlertController(title: "激活成功",
                                      message: "卡密验证通过，已解锁全部功能。",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "进入", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let vc = MainViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }))
        present(alert, animated: true)
    }
}
