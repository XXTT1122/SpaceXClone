import UIKit

/// 固件页：列表 / 下载（带进度）/ 已下载文件管理
final class FirmwareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let bg = StarfieldView()
    private let header = UILabel()
    private let seg = UISegmentedControl(items: ["可下载", "已下载"])
    private let table = UITableView(frame: .zero, style: .plain)
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()
    private let closeBtn = UIButton(type: .system)

    private var firmwares: [Firmware] = []
    private var files: [URL] = []
    private var downloading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        build()
        loadFiles()
    }

    private func build() {
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)

        header.text = "固件 / Kernelcache"
        header.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        header.textColor = .white
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = UIColor(red: 0.15, green: 0.30, blue: 0.62, alpha: 1)
        seg.addTarget(self, action: #selector(onSeg), for: .valueChanged)
        seg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seg)

        table.backgroundColor = .clear
        table.separatorColor = UIColor(white: 1, alpha: 0.1)
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        progressBar.progressTintColor = UIColor(red: 0.35, green: 0.85, blue: 0.60, alpha: 1)
        progressBar.isHidden = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)

        progressLabel.font = UIFont.systemFont(ofSize: 11)
        progressLabel.textColor = UIColor(white: 0.75, alpha: 1)
        progressLabel.text = ""
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        closeBtn.setTitle("返回", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        closeBtn.backgroundColor = UIColor(white: 1, alpha: 0.10)
        closeBtn.layer.cornerRadius = 10
        closeBtn.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeBtn)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            header.topAnchor.constraint(equalTo: g.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            closeBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeBtn.widthAnchor.constraint(equalToConstant: 64),
            closeBtn.heightAnchor.constraint(equalToConstant: 34),

            seg.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 14),
            seg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            seg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            table.topAnchor.constraint(equalTo: seg.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            table.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -8),

            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.bottomAnchor.constraint(equalTo: progressLabel.topAnchor, constant: -4),
            progressBar.heightAnchor.constraint(equalToConstant: 3),

            progressLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -12),
            progressLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    // MARK: - 数据

    private func loadFiles() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        files = (try? FileManager.default.contentsOfDirectory(at: docs,
                                                              includingPropertiesForKeys: [.fileSizeKey],
                                                              options: .skipsHiddenFiles)) ?? []
        files.sort { $0.lastPathComponent < $1.lastPathComponent }
        table.reloadData()
    }

    @objc private func onSeg() {
        if seg.selectedSegmentIndex == 0 {
            if firmwares.isEmpty { fetch() }
        } else {
            loadFiles()
        }
        table.reloadData()
    }

    private func fetch() {
        header.text = "正在获取固件列表…"
        IPSWService.shared.fetchFirmwares(deviceId: DeviceInfo.machineId) { [weak self] list in
            guard let self = self else { return }
            self.firmwares = list
            self.header.text = "固件 / Kernelcache（\(list.count) 个）"
            self.table.reloadData()
        }
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        seg.selectedSegmentIndex == 0 ? firmwares.count : files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)

        if seg.selectedSegmentIndex == 0 {
            let fw = firmwares[indexPath.row]
            let mb = Double(fw.size) / 1024 / 1024
            cell.textLabel?.text = String(format: "iOS %@  (%@)\n%.0f MB", fw.version, fw.build, mb)
            cell.accessoryType = .disclosureIndicator
        } else {
            let url = files[indexPath.row]
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            cell.textLabel?.text = String(format: "%@\n%.1f MB", url.lastPathComponent,
                                          Double(size) / 1024 / 1024)
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard seg.selectedSegmentIndex == 0, !downloading else { return }
        let fw = firmwares[indexPath.row]
        confirmDownload(fw)
    }

    private func confirmDownload(_ fw: Firmware) {
        let mb = Double(fw.size) / 1024 / 1024
        let ac = UIAlertController(title: "下载固件",
                                   message: String(format: "iOS %@ (%@)\n%.0f MB",
                                                   fw.version, fw.build, mb),
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        ac.addAction(UIAlertAction(title: "下载", style: .default) { _ in
            self.startDownload(fw)
        })
        present(ac, animated: true)
    }

    private func startDownload(_ fw: Firmware) {
        downloading = true
        progressBar.isHidden = false
        progressBar.progress = 0
        progressLabel.text = "准备下载…"

        IPSWService.shared.download(fw, progress: { p in
            self.progressBar.progress = Float(p)
            self.progressLabel.text = String(format: "下载中 %.0f%%", p * 100)
        }, completion: { result in
            self.downloading = false
            self.progressBar.isHidden = true
            switch result {
            case .success(let url):
                self.progressLabel.text = "已保存：\(url.lastPathComponent)"
                self.loadFiles()
                self.seg.selectedSegmentIndex = 1
                self.table.reloadData()
                let ok = UIAlertController(title: "下载完成",
                                           message: "已保存到 App 的 Documents 目录，可在「文件」App 中查看。",
                                           preferredStyle: .alert)
                ok.addAction(UIAlertAction(title: "好", style: .default))
                self.present(ok, animated: true)
            case .failure(let e):
                self.progressLabel.text = "失败：\(e.localizedDescription)"
            }
        })
    }

    @objc private func onClose() { dismiss(animated: true) }
}
