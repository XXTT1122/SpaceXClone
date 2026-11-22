import UIKit

/// 激活成功后的功能页（占位：后续接 kernelcache 下载 / 内核符号查询）
final class MainViewController: UIViewController {

    private let bg = StarfieldView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)

        titleLabel.text = "已激活"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.systemFont(ofSize: 15)
        infoLabel.textColor = UIColor(white: 0.85, alpha: 1)
        infoLabel.text = """
        功能页（开发中）

        · 选择 iOS 版本下载 kernelcache
        · 查看内核符号与偏移
        · 导出结果
        """
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        closeButton.setTitle("返回激活页", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton.backgroundColor = UIColor(red: 0.15, green: 0.25, blue: 0.50, alpha: 0.9)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        view.addSubview(closeButton)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),

            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            closeButton.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -40),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func onClose() {
        dismiss(animated: true)
    }
}
