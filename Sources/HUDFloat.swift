import UIKit

/// 悬浮按钮 HUD：可拖动、边缘吸附、点击回到主界面
final class HUDFloat {

    static let shared = HUDFloat()

    private var window: UIWindow?
    private var button: UIButton?
    private var panStart: CGPoint = .zero

    private let size: CGFloat = 56

    /// 显示悬浮球
    func show(onTap: @escaping () -> Void) {
        guard window == nil else { return }
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        let w = UIWindow(windowScene: scene)
        w.windowLevel = .alert + 1
        w.backgroundColor = .clear
        w.rootViewController = UIViewController()
        w.rootViewController?.view.backgroundColor = .clear

        let b = UIButton(type: .custom)
        b.frame = CGRect(x: scene.screen.bounds.width - size - 16,
                         y: scene.screen.bounds.height * 0.42,
                         width: size, height: size)
        b.backgroundColor = UIColor(red: 0.15, green: 0.28, blue: 0.62, alpha: 0.92)
        b.layer.cornerRadius = size / 2
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor(white: 1, alpha: 0.35).cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.45
        b.layer.shadowRadius = 8
        b.layer.shadowOffset = .zero
        b.setTitle("S", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        b.addTarget(self, action: #selector(onTapped), for: .touchUpInside)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        b.addGestureRecognizer(pan)

        self.tapHandler = onTap
        w.rootViewController?.view.addSubview(b)
        w.isHidden = false
        self.window = w
        self.button = b
    }

    private var tapHandler: (() -> Void)?

    @objc private func onTapped() {
        tapHandler?()
    }

    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        guard let b = button, let w = window else { return }
        let t = g.translation(in: b.superview)
        switch g.state {
        case .began:
            panStart = b.center
        case .changed:
            b.center = CGPoint(x: panStart.x + t.x, y: panStart.y + t.y)
        case .ended, .cancelled:
            // 边缘吸附
            let bounds = w.bounds
            let margin: CGFloat = 8
            var c = b.center
            let leftX = size / 2 + margin
            let rightX = bounds.width - size / 2 - margin
            c.x = (c.x < bounds.width / 2) ? leftX : rightX
            let topY = size / 2 + 60
            let bottomY = bounds.height - size / 2 - 40
            c.y = max(topY, min(bottomY, c.y))
            UIView.animate(withDuration: 0.2) { b.center = c }
        default: break
        }
    }

    func hide() {
        window?.isHidden = true
        window = nil
        button = nil
    }

    var isVisible: Bool { window != nil }
}
