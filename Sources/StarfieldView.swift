import UIKit

/// 深色星空背景：渐变 + 星点 + 流星 + 大月亮（照 SpaceX 截图复刻）
final class StarfieldView: UIView {

    private struct Star {
        let x: CGFloat
        let y: CGFloat
        let r: CGFloat
        let a: CGFloat
    }

    private var stars: [Star] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = true
        backgroundColor = UIColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        if stars.isEmpty { seed() }
    }

    private func seed() {
        var list: [Star] = []
        list.reserveCapacity(180)
        for _ in 0..<180 {
            list.append(Star(x: CGFloat.random(in: 0...1),
                             y: CGFloat.random(in: 0...1),
                             r: CGFloat.random(in: 0.6...1.9),
                             a: CGFloat.random(in: 0.25...1.0)))
        }
        stars = list
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // 背景竖向渐变
        let colors = [
            UIColor(red: 0.020, green: 0.030, blue: 0.070, alpha: 1).cgColor,
            UIColor(red: 0.050, green: 0.080, blue: 0.160, alpha: 1).cgColor
        ] as CFArray
        if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: colors,
                                 locations: [0, 1]) {
            ctx.drawLinearGradient(grad,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: rect.height),
                                   options: [])
        }

        // 星点
        for s in stars {
            let p = CGPoint(x: s.x * rect.width, y: s.y * rect.height)
            ctx.setFillColor(UIColor(white: 1.0, alpha: s.a).cgColor)
            ctx.fillEllipse(in: CGRect(x: p.x - s.r, y: p.y - s.r,
                                       width: s.r * 2, height: s.r * 2))
        }

        // 流星线
        ctx.setStrokeColor(UIColor(white: 1.0, alpha: 0.10).cgColor)
        ctx.setLineWidth(1.0)
        for i in 0..<3 {
            let y = rect.height * (0.10 + CGFloat(i) * 0.055)
            ctx.move(to: CGPoint(x: rect.width * 0.52, y: y))
            ctx.addLine(to: CGPoint(x: rect.width * 0.96, y: y - 30))
            ctx.strokePath()
        }

        // 大月亮（月牙：亮圆 + 背景色遮挡）
        let moon = CGRect(x: rect.width * 0.66, y: rect.height * 0.025,
                          width: 82, height: 82)
        ctx.setFillColor(UIColor(red: 0.72, green: 0.78, blue: 0.95, alpha: 0.95).cgColor)
        ctx.fillEllipse(in: moon)
        ctx.setFillColor(UIColor(red: 0.050, green: 0.080, blue: 0.160, alpha: 1).cgColor)
        ctx.fillEllipse(in: moon.offsetBy(dx: 24, dy: -12))
    }
}
