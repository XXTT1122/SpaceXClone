import UIKit

/// 主功能页：AX 的功能清单（主题设置 / 过直播 / 防截屏 / 固件下载）+ SpaceX 的星空界面
final class MainViewController: UIViewController {

    // MARK: - 状态

    private var hue: CGFloat {
        get { CGFloat(UserDefaults.standard.double(forKey: "ax.hue")) }
        set { UserDefaults.standard.set(Double(newValue), forKey: "ax.hue") }
    }
    private var saturation: CGFloat {
        get {
            let v = UserDefaults.standard.double(forKey: "ax.sat")
            return v == 0 ? 0.8 : CGFloat(v)
        }
        set { UserDefaults.standard.set(Double(newValue), forKey: "ax.sat") }
    }
    private var brightness: CGFloat {
        get {
            let v = UserDefaults.standard.double(forKey: "ax.bri")
            return v == 0 ? 1.0 : CGFloat(v)
        }
        set { UserDefaults.standard.set(Double(newValue), forKey: "ax.bri") }
    }
    private var passLive: Bool {
        get { UserDefaults.standard.bool(forKey: "ax.passlive") }
        set { UserDefaults.standard.set(newValue, forKey: "ax.passlive") }
    }
    private var antiShot: Bool {
        get {
            if UserDefaults.standard.object(forKey: "ax.antishot") == nil { return true }
            return UserDefaults.standard.bool(forKey: "ax.antishot")
        }
        set { UserDefaults.standard.set(newValue, forKey: "ax.antishot") }
    }

    // MARK: - 视图

    private let bg = StarfieldView()
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "SpaceX"
        l.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let subLabel: UILabel = {
        let l = UILabel()
        l.text = "VERSION 1.1 · 已激活"
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor(red: 0.35, green: 0.95, blue: 0.65, alpha: 1)
        return l
    }()

    private let themeCard = UIView()
    private let themePreview = UIView()
    private let hueSlider = UISlider()
    private let satSlider = UISlider()
    private let briSlider = UISlider()
    private let colorRow = UIStackView()

    private let switchCard = UIView()
    private let passLiveSwitch = UISwitch()
    private let antiShotSwitch = UISwitch()

    private let firmwareCard = UIView()
    private let firmwareLabel = UILabel()
    private let firmwareButton = UIButton(type: .system)
    private let firmwareList = UIStackView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildUI()
        applyTheme()
    }

    // MARK: - 构建界面

    private func buildUI() {
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // 标题
        let header = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        header.axis = .vertical
        header.spacing = 2
        stack.addArrangedSubview(header)

        // 主题卡片
        stack.addArrangedSubview(themeCard)
        buildThemeCard()

        // 开关卡片
        stack.addArrangedSubview(switchCard)
        buildSwitchCard()

        // 固件卡片
        stack.addArrangedSubview(firmwareCard)
        buildFirmwareCard()

        // 工具入口
        let tools = UIButton(type: .system)
        tools.setTitle("设备信息 / 工具 / 网络诊断", for: .normal)
        tools.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tools.setTitleColor(.white, for: .normal)
        tools.backgroundColor = UIColor(red: 0.15, green: 0.30, blue: 0.62, alpha: 0.95)
        tools.layer.cornerRadius = 12
        tools.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tools.addTarget(self, action: #selector(onTools), for: .touchUpInside)
        stack.addArrangedSubview(tools)

        // 固件页入口
        let fw = UIButton(type: .system)
        fw.setTitle("固件下载 / 文件管理", for: .normal)
        fw.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        fw.setTitleColor(.white, for: .normal)
        fw.backgroundColor = UIColor(red: 0.12, green: 0.42, blue: 0.35, alpha: 0.95)
        fw.layer.cornerRadius = 12
        fw.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fw.addTarget(self, action: #selector(onFirmware), for: .touchUpInside)
        stack.addArrangedSubview(fw)

        // 悬浮窗开关
        let hudBtn = UIButton(type: .system)
        hudBtn.setTitle("显示悬浮球", for: .normal)
        hudBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        hudBtn.setTitleColor(.white, for: .normal)
        hudBtn.backgroundColor = UIColor(red: 0.32, green: 0.22, blue: 0.55, alpha: 0.95)
        hudBtn.layer.cornerRadius = 12
        hudBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        hudBtn.addTarget(self, action: #selector(onHUD), for: .touchUpInside)
        stack.addArrangedSubview(hudBtn)

        // 关闭
        let close = UIButton(type: .system)
        close.setTitle("退出 HUD", for: .normal)
        close.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        close.setTitleColor(.white, for: .normal)
        close.backgroundColor = UIColor(red: 0.35, green: 0.12, blue: 0.16, alpha: 0.9)
        close.layer.cornerRadius = 12
        close.heightAnchor.constraint(equalToConstant: 48).isActive = true
        close.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        stack.addArrangedSubview(close)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: g.topAnchor, constant: 16),
            scroll.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])
    }

    private func styleCard(_ v: UIView) {
        v.backgroundColor = UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 0.82)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.0
        v.layer.borderColor = UIColor(red: 0.22, green: 0.35, blue: 0.65, alpha: 0.8).cgColor
    }

    private func cardTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(white: 0.72, alpha: 1)
        return l
    }

    private func buildThemeCard() {
        styleCard(themeCard)
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 10
        inner.translatesAutoresizingMaskIntoConstraints = false
        themeCard.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: themeCard.topAnchor, constant: 14),
            inner.bottomAnchor.constraint(equalTo: themeCard.bottomAnchor, constant: -14),
            inner.leadingAnchor.constraint(equalTo: themeCard.leadingAnchor, constant: 14),
            inner.trailingAnchor.constraint(equalTo: themeCard.trailingAnchor, constant: -14)
        ])

        inner.addArrangedSubview(cardTitle("主题设置"))

        themePreview.heightAnchor.constraint(equalToConstant: 52).isActive = true
        themePreview.layer.cornerRadius = 10
        themePreview.layer.borderWidth = 1
        themePreview.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        inner.addArrangedSubview(themePreview)

        for (label, slider, minV) in [("色相", hueSlider, Float(0)), ("饱和度", satSlider, Float(0)), ("亮度", briSlider, Float(0.2))] {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            let l = UILabel()
            l.text = label
            l.font = UIFont.systemFont(ofSize: 12)
            l.textColor = UIColor(white: 0.65, alpha: 1)
            l.widthAnchor.constraint(equalToConstant: 48).isActive = true
            slider.minimumValue = minV
            slider.maximumValue = 1
            slider.addTarget(self, action: #selector(onThemeChanged), for: .valueChanged)
            row.addArrangedSubview(l)
            row.addArrangedSubview(slider)
            inner.addArrangedSubview(row)
        }
        hueSlider.value = Float(hue)
        satSlider.value = Float(saturation)
        briSlider.value = Float(brightness)

        // 预设颜色
        colorRow.axis = .horizontal
        colorRow.spacing = 8
        colorRow.distribution = .fillEqually
        let presets: [(String, CGFloat)] = [
            ("蓝", 0.58), ("紫", 0.75), ("青", 0.50),
            ("绿", 0.33), ("橙", 0.08), ("红", 0.0), ("粉", 0.90)
        ]
        for (name, h) in presets {
            let b = UIButton(type: .system)
            b.setTitle(name, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            b.setTitleColor(.white, for: .normal)
            b.backgroundColor = UIColor(hue: h, saturation: 0.65, brightness: 0.95, alpha: 1)
            b.layer.cornerRadius = 7
            b.heightAnchor.constraint(equalToConstant: 30).isActive = true
            b.tag = Int(h * 1000)
            b.addTarget(self, action: #selector(onPreset(_:)), for: .touchUpInside)
            colorRow.addArrangedSubview(b)
        }
        inner.addArrangedSubview(colorRow)

        let reset = UIButton(type: .system)
        reset.setTitle("恢复默认蓝色", for: .normal)
        reset.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        reset.setTitleColor(UIColor(red: 0.45, green: 0.70, blue: 1, alpha: 1), for: .normal)
        reset.addTarget(self, action: #selector(onResetTheme), for: .touchUpInside)
        inner.addArrangedSubview(reset)
    }

    private func buildSwitchCard() {
        styleCard(switchCard)
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        switchCard.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: switchCard.topAnchor, constant: 14),
            inner.bottomAnchor.constraint(equalTo: switchCard.bottomAnchor, constant: -14),
            inner.leadingAnchor.constraint(equalTo: switchCard.leadingAnchor, constant: 14),
            inner.trailingAnchor.constraint(equalTo: switchCard.trailingAnchor, constant: -14)
        ])
        inner.addArrangedSubview(cardTitle("功能开关"))

        func row(_ title: String, _ sw: UISwitch, _ action: Selector) -> UIStackView {
            let r = UIStackView()
            r.axis = .horizontal
            let l = UILabel()
            l.text = title
            l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            l.textColor = .white
            sw.addTarget(self, action: action, for: .valueChanged)
            r.addArrangedSubview(l)
            r.addArrangedSubview(UIView())
            r.addArrangedSubview(sw)
            return r
        }

        passLiveSwitch.isOn = passLive
        antiShotSwitch.isOn = antiShot
        inner.addArrangedSubview(row("过直播", passLiveSwitch, #selector(onPassLive)))
        inner.addArrangedSubview(row("防截屏", antiShotSwitch, #selector(onAntiShot)))
    }

    private func buildFirmwareCard() {
        styleCard(firmwareCard)
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 10
        inner.translatesAutoresizingMaskIntoConstraints = false
        firmwareCard.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: firmwareCard.topAnchor, constant: 14),
            inner.bottomAnchor.constraint(equalTo: firmwareCard.bottomAnchor, constant: -14),
            inner.leadingAnchor.constraint(equalTo: firmwareCard.leadingAnchor, constant: 14),
            inner.trailingAnchor.constraint(equalTo: firmwareCard.trailingAnchor, constant: -14)
        ])
        inner.addArrangedSubview(cardTitle("固件 / Kernelcache"))

        firmwareLabel.font = UIFont.systemFont(ofSize: 13)
        firmwareLabel.textColor = UIColor(white: 0.70, alpha: 1)
        firmwareLabel.numberOfLines = 0
        firmwareLabel.text = "点击获取本机可用固件列表"
        inner.addArrangedSubview(firmwareLabel)

        firmwareButton.setTitle("获取固件列表", for: .normal)
        firmwareButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        firmwareButton.setTitleColor(.white, for: .normal)
        firmwareButton.backgroundColor = UIColor(red: 0.15, green: 0.30, blue: 0.62, alpha: 0.95)
        firmwareButton.layer.cornerRadius = 10
        firmwareButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        firmwareButton.addTarget(self, action: #selector(onFetchFirmware), for: .touchUpInside)
        inner.addArrangedSubview(firmwareButton)

        firmwareList.axis = .vertical
        firmwareList.spacing = 6
        inner.addArrangedSubview(firmwareList)
    }

    // MARK: - 主题

    private func applyTheme() {
        hue = hueSlider.value.isNaN ? 0.58 : CGFloat(hueSlider.value)
        saturation = CGFloat(satSlider.value)
        brightness = CGFloat(briSlider.value)
        let c = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        themePreview.backgroundColor = c
        // 让卡片边框跟着主题变色
        for v in [themeCard, switchCard, firmwareCard] {
            v.layer.borderColor = c.withAlphaComponent(0.6).cgColor
        }
    }

    @objc private func onThemeChanged() { applyTheme() }

    @objc private func onPreset(_ sender: UIButton) {
        hueSlider.value = Float(sender.tag) / 1000.0
        applyTheme()
    }

    @objc private func onResetTheme() {
        hueSlider.value = 0.58
        satSlider.value = 0.8
        briSlider.value = 1.0
        applyTheme()
    }

    // MARK: - 开关

    @objc private func onPassLive(_ sw: UISwitch) {
        passLive = sw.isOn
        toast(sw.isOn ? "过直播 已开启" : "过直播 已关闭")
    }

    @objc private func onAntiShot(_ sw: UISwitch) {
        antiShot = sw.isOn
        toast(sw.isOn ? "防截屏已开启" : "允许截屏")
    }

    // MARK: - 固件

    @objc private func onFetchFirmware() {
        firmwareButton.isEnabled = false
        firmwareLabel.text = "正在获取…"
        // 当前设备型号
        var info = utsname()
        uname(&info)
        let id = withUnsafeBytes(of: &info.machine) { raw -> String in
            String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
        }
        IPSWService.shared.fetchFirmwares(deviceId: id) { [weak self] list in
            guard let self = self else { return }
            self.firmwareButton.isEnabled = true
            self.firmwareList.arrangedSubviews.forEach { $0.removeFromSuperview() }
            if list.isEmpty {
                self.firmwareLabel.text = "获取失败，请检查网络"
                return
            }
            self.firmwareLabel.text = "\(id) 共 \(list.count) 个可用固件"
            for fw in list.prefix(8) {
                let b = UIButton(type: .system)
                let mb = Double(fw.size) / 1024.0 / 1024.0
                b.setTitle(String(format: "iOS %@  (%@)  %.0f MB", fw.version, fw.build, mb), for: .normal)
                b.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                b.setTitleColor(.white, for: .normal)
                b.backgroundColor = UIColor(white: 1, alpha: 0.08)
                b.layer.cornerRadius = 8
                b.heightAnchor.constraint(equalToConstant: 36).isActive = true
                b.contentHorizontalAlignment = .left
                b.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                self.firmwareList.addArrangedSubview(b)
            }
        }
    }

    // MARK: - 其它

    @objc private func onClose() {
        dismiss(animated: true)
    }

    @objc private func onTools() {
        let vc = ToolsViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func onFirmware() {
        let vc = FirmwareViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func onHUD() {
        if HUDFloat.shared.isVisible {
            HUDFloat.shared.hide()
            toast("悬浮球已关闭")
        } else {
            HUDFloat.shared.show { [weak self] in
                HUDFloat.shared.hide()
                self?.toast("已回到主界面")
            }
            toast("悬浮球已显示，可拖动，点击回到主界面")
        }
    }

    private func toast(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { alert.dismiss(animated: true) }
    }
}
