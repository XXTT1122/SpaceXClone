# SpaceXClone

自建卡密系统的 iOS 工具壳（ImGui 风格 UI → UIKit 复刻），卡密直接接你现有的 AX 授权服务器。

## 已实现

- 激活页 UI（照 SpaceX 截图复刻：星空背景 / 绿色设备卡片 / 卡密输入 / 激活按钮 / 状态栏）
- 设备与系统检测（机型 + iOS 版本，iPhone XS ~ 16 系列全覆盖）
- 卡密验证（内置你的 RSA 公钥，连你的服务器，RSA-PSS-SHA256 验签）
- 三种状态展示：激活成功 / 卡密无效 / 卡密已过期
- 激活后进入功能页（当前为占位，后续接 kernelcache 下载与符号查询）

## 配置位置

| 配置 | 文件 | 行 |
|---|---|---|
| 服务器地址 | `Sources/CardService.swift` | `private let host = "192.168.1.112"` |
| app_key | 同上 | `private let appKey = "..."` |
| RSA 公钥 | 同上 | `private let pubKeyB64 = "..."` |
| 最低系统 | `project.yml` | `MinimumOSVersion: "15.0"` |
| Bundle ID | `project.yml` | `PRODUCT_BUNDLE_IDENTIFIER` |

## 云编译步骤（GitHub Actions）

1. 在 GitHub 新建仓库（Private 或 Public 都行）
2. 把本目录所有文件上传（网页拖拽即可，注意 `.github` 文件夹也要传）
3. 进入仓库 **Actions** 页 → 左侧选 `Build IPA` → 右侧 **Run workflow**
4. 等 5-10 分钟（首次会装 XcodeGen，稍慢）
5. 构建完成后，点进这次运行 → 页面底部 **Artifacts** → 下载 `SpaceXClone-ipa`
6. 解压得到 `SpaceXClone.ipa`

## 装机

用自签工具（全能签 / Sideloadly / AltStore）签名安装即可。产物是**未签名 ipa**，必须自签。

## 卡密流程

```
App 启动 → 输入卡密 → 点「卡密激活」
   ↓
GET https://<host>/api/v1/client/probe?app_key=<appKey>&nonce=<随机>
   ↓
服务器返回 { nonce, payload, signature }
   ↓
App 用内置公钥验 RSA-PSS-SHA256 签名（签名对象：KVRESP-V1\n<nonce>\n<payload>）
   ↓
payload.status = ok / invalid / expired → 显示对应状态
payload.expire_date → 显示到期日
```

服务器端（已在你机器上跑着）：

- `ax_auth_server.ps1` — 443 端口授权服务
- `ax_admin.ps1` — 8081 端口管理后台（发卡/续费/封禁/导出）
- `keys/cards.txt` — 卡密库

## 已知限制

- 功能页目前是占位（kernelcache 下载等未接）
- 服务器地址是局域网 IP，外网使用需要换成公网域名 + 有效证书
- 未做证书固定（自己的 App 不需要）

## 目录结构

```
spacex_clone/
├── project.yml                     XcodeGen 工程描述
├── Sources/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ActivationViewController.swift   激活页
│   ├── MainViewController.swift         功能页（占位）
│   ├── CardService.swift                卡密验证 + 验签
│   └── StarfieldView.swift              星空背景
└── .github/workflows/build.yml     云编译配置
```
