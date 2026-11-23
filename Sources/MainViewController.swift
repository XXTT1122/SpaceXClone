import UIKit

/// 主界面：只保留 AX 的功能（主题设置 / 过直播 / 防截屏 / 退出）+ SpaceX 星空风格
final class MainViewController: UIViewController {

    // MARK: - 配置存储

    private var hue: CGFloat {
        get {
            let v = UserDefaults.standard.double(forKey: "ax.hue")
            return v == 0 ? 0.58 : CGFloat(v)
        }
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
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let versionLabel: UILabel = {
        let l = UILabel()
        l.text = "VERSION 1.1"
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor(white: 0.62, alpha: 1)
        return l
    }()

    private let preview = UIView()
    private let hueSlider = UISlider()
    private let satSlider = UISlider()
    private let briSlider = UISlider()
    private let themeCard = UIView()
    private let switchCard = UIView()
    private let passLiveSwitch = UISwitch()
    private let antiShotSwitch = UISwitch()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        build()
        refreshTheme()
    }

    // MARK: - 构建

    private func card(_ v: UIView) {
        v.backgroundColor = UIColor(red: 0.06, green: 0.10, blue: 0.20, alpha: 0.85)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
    }

    private func sectionTitle(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(white: 0.70, alpha: 1)
        return l
    }

    private func sliderRow(_ name: String, _ slider: UISlider) -> UIStackView {
        let r = UIStackView()
        r.axis = .horizontal
        r.spacing = 10
        let l = UILabel()
        l.text = name
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor(white: 0.62, alpha: 1)
        l.widthAnchor.constraint(equalToConstant: 46).isActive = true
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(onSlider), for: .valueChanged)
        r.addArrangedSubview(l)
        r.addArrangedSubview(slider)
        return r
    }

    private func switchRow(_ name: String, _ sw: UISwitch, _ sel: Selector) -> UIStackView {
        let r = UIStackView()
        r.axis = .horizontal
        let l = UILabel()
        l.text = name
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = .white
        sw.addTarget(self, action: sel, for: .valueChanged)
        r.addArrangedSubview(l)
        r.addArrangedSubview(UIView())
        r.addArrangedSubview(sw)
        return r
    }

    private func build() {
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)

        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // 标题
        let header = UIStackView(arrangedSubviews: [titleLabel, versionLabel])
        header.axis = .vertical
        header.spacing = 0
        stack.addArrangedSubview(header)

        // ===== 主题设置 =====
        card(themeCard)
        let themeInner = UIStackView()
        themeInner.axis = .vertical
        themeInner.spacing = 10
        themeInner.translatesAutoresizingMaskIntoConstraints = false
        themeCard.addSubview(themeInner)
        NSLayoutConstraint.activate([
            themeInner.topAnchor.constraint(equalTo: themeCard.topAnchor, constant: 14),
            themeInner.bottomAnchor.constraint(equalTo: themeCard.bottomAnchor, constant: -14),
            themeInner.leadingAnchor.constraint(equalTo: themeCard.leadingAnchor, constant: 14),
            themeInner.trailingAnchor.constraint(equalTo: themeCard.trailingAnchor, constant: -14)
        ])
        themeInner.addArrangedSubview(sectionTitle("主题设置"))

        preview.heightAnchor.constraint(equalToConstant: 48).isActive = true
        preview.layer.cornerRadius = 10
        preview.layer.borderWidth = 1
        preview.layer.borderColor = UIColor(white: 1, alpha: 0.18).cgColor
        themeInner.addArrangedSubview(preview)

        hueSlider.value = Float(hue)
        satSlider.value = Float(saturation)
        briSlider.value = Float(brightness)
        themeInner.addArrangedSubview(sliderRow("色相", hueSlider))
        themeInner.addArrangedSubview(sliderRow("饱和度", satSlider))
        themeInner.addArrangedSubview(sliderRow("亮度", briSlider))

        // 预设颜色
        let colors: [(String, CGFloat)] = [
            ("蓝", 0.58), ("紫", 0.75), ("青", 0.50), ("绿", 0.33),
            ("橙", 0.08), ("红", 0.0), ("粉", 0.90)
        ]
        let colorRow = UIStackView()
        colorRow.axis = .horizontal
        colorRow.spacing = 6
        colorRow.distribution = .fillEqually
        for (name, h) in colors {
            let b = UIButton(type: .system)
            b.setTitle(name, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            b.setTitleColor(.white, for: .normal)
            b.backgroundColor = UIColor(hue: h, saturation: 0.68, brightness: 0.95, alpha: 1)
            b.layer.cornerRadius = 7
            b.heightAnchor.constraint(equalToConstant: 30).isActive = true
            b.tag = Int(h * 1000)
            b.addTarget(self, action: #selector(onPreset(_:)), for: .touchUpInside)
            colorRow.addArrangedSubview(b)
        }
        themeInner.addArrangedSubview(colorRow)

        let reset = UIButton(type: .system)
        reset.setTitle("恢复默认蓝色", for: .normal)
        reset.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        reset.setTitleColor(UIColor(red: 0.45, green: 0.72, blue: 1, alpha: 1), for: .normal)
        reset.addTarget(self, action: #selector(onResetTheme), for: .touchUpInside)
        themeInner.addArrangedSubview(reset)

        stack.addArrangedSubview(themeCard)

        // ===== 功能开关 =====
        card(switchCard)
        let switchInner = UIStackView()
        switchInner.axis = .vertical
        switchInner.spacing = 12
        switchInner.translatesAutoresizingMaskIntoConstraints = false
        switchCard.addSubview(switchInner)
        NSLayoutConstraint.activate([
            switchInner.topAnchor.constraint(equalTo: switchCard.topAnchor, constant: 14),
            switchInner.bottomAnchor.constraint(equalTo: switchCard.bottomAnchor, constant: -14),
            switchInner.leadingAnchor.constraint(equalTo: switchCard.leadingAnchor, constant: 14),
            switchInner.trailingAnchor.constraint(equalTo: switchCard.trailingAnchor, constant: -14)
        ])
        switchInner.addArrangedSubview(sectionTitle("功能开关"))
        passLiveSwitch.isOn = passLive
        antiShotSwitch.isOn = antiShot
        switchInner.addArrangedSubview(switchRow("过直播", passLiveSwitch, #selector(onPassLive)))
        switchInner.addArrangedSubview(switchRow("防截屏", antiShotSwitch, #selector(onAntiShot)))
        stack.addArrangedSubview(switchCard)

        // ===== 悬浮球 =====
        let hudBtn = UIButton(type: .system)
        hudBtn.setTitle("显示悬浮球", for: .normal)
        hudBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        hudBtn.setTitleColor(.white, for: .normal)
        hudBtn.backgroundColor = UIColor(red: 0.28, green: 0.22, blue: 0.55, alpha: 0.95)
        hudBtn.layer.cornerRadius = 12
        hudBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        hudBtn.addTarget(self, action: #selector(onHUD), for: .touchUpInside)
        stack.addArrangedSubview(hudBtn)

        // ===== 退出 HUD =====
        let close = UIButton(type: .system)
        close.setTitle("退出 HUD", for: .normal)
        close.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        close.setTitleColor(.white, for: .normal)
        close.backgroundColor = UIColor(red: 0.42, green: 0.14, blue: 0.18, alpha: 0.95)
        close.layer.cornerRadius = 12
        close.heightAnchor.constraint(equalToConstant: 46).isActive = true
        close.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        stack.addArrangedSubview(close)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: g.topAnchor, constant: 20),
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

    // MARK: - 主题

    private func refreshTheme() {
        hue = CGFloat(hueSlider.value)
        saturation = CGFloat(satSlider.value)
        brightness = CGFloat(briSlider.value)
        let c = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        preview.backgroundColor = c
        themeCard.layer.borderColor = c.withAlphaComponent(0.55).cgColor
        switchCard.layer.borderColor = c.withAlphaComponent(0.55).cgColor
    }

    @objc private func onSlider() { refreshTheme() }

    @objc private func onPreset(_ sender: UIButton) {
        hueSlider.value = Float(sender.tag) / 1000.0
        refreshTheme()
    }

    @objc private func onResetTheme() {
        hueSlider.value = 0.58
        satSlider.value = 0.8
        briSlider.value = 1.0
        refreshTheme()
    }

    // MARK: - 开关

    @objc private func onPassLive(_ sw: UISwitch) {
        passLive = sw.isOn
        tip(sw.isOn ? "过直播 已开启" : "过直播 已关闭")
    }

    @objc private func onAntiShot(_ sw: UISwitch) {
        antiShot = sw.isOn
        tip(sw.isOn ? "防截屏已开启" : "允许截屏")
    }

    // MARK: - 悬浮球 / 退出

    @objc private func onHUD() {
        if HUDFloat.shared.isVisible {
            HUDFloat.shared.hide()
            tip("悬浮球已关闭")
        } else {
            HUDFloat.shared.show { [weak self] in
                HUDFloat.shared.hide()
                self?.tip("已回到主界面")
            }
            tip("悬浮球已显示，可拖动")
        }
    }

    @objc private func onClose() {
        HUDFloat.shared.hide()
        dismiss(animated: true)
    }

    private func tip(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        present(a, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { a.dismiss(animated: true) }
    }
}
