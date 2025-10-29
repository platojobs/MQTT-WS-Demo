//
//  GatewayDemoViewController.swift
//  AiPlanner
//
//  Zigbee 网关 Demo 控制器（WebSocket 示意）
//

import UIKit
import SVProgressHUD

final class GatewayDemoViewController: BaseViewController {
    private let client = GatewayMQClient()

    private let urlField = UITextField()
    private let connectButton = UIButton(type: .system)
    private let logView = UITextView()
    private let onButton = UIButton(type: .system)
    private let offButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Zigbee 网关 Demo"
        view.backgroundColor = .white
        setupUI()
        wireEvents()
    }

    private func setupUI() {
        urlField.placeholder = "ws://192.168.1.2:8080/ws"
        urlField.borderStyle = .roundedRect
        connectButton.setTitle("连接", for: .normal)

        logView.isEditable = false
        logView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        logView.layer.cornerRadius = 8

        onButton.setTitle("群组开 (group/0xC123)", for: .normal)
        onButton.backgroundColor = AiThemColor.app_tintColor
        onButton.setTitleColor(.white, for: .normal)
        onButton.layer.cornerRadius = 8

        offButton.setTitle("群组关 (group/0xC123)", for: .normal)
        offButton.backgroundColor = .systemGray
        offButton.setTitleColor(.white, for: .normal)
        offButton.layer.cornerRadius = 8

        [urlField, connectButton, logView, onButton, offButton].forEach { view.addSubview($0) }
        [urlField, connectButton, logView, onButton, offButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            urlField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            urlField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            urlField.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -8),
            urlField.heightAnchor.constraint(equalToConstant: 44),

            connectButton.centerYAnchor.constraint(equalTo: urlField.centerYAnchor),
            connectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            connectButton.widthAnchor.constraint(equalToConstant: 80),
            connectButton.heightAnchor.constraint(equalToConstant: 44),

            logView.topAnchor.constraint(equalTo: urlField.bottomAnchor, constant: 12),
            logView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logView.heightAnchor.constraint(equalToConstant: 260),

            onButton.topAnchor.constraint(equalTo: logView.bottomAnchor, constant: 16),
            onButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onButton.heightAnchor.constraint(equalToConstant: 50),

            offButton.topAnchor.constraint(equalTo: onButton.bottomAnchor, constant: 12),
            offButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            offButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            offButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func wireEvents() {
        connectButton.addTarget(self, action: #selector(toggleConnect), for: .touchUpInside)
        onButton.addTarget(self, action: #selector(sendOn), for: .touchUpInside)
        offButton.addTarget(self, action: #selector(sendOff), for: .touchUpInside)

        client.onMessage = { [weak self] t in self?.appendLog("MSG: \(t)") }
        client.onLog = { [weak self] t in self?.appendLog(t) }
    }

    @objc private func toggleConnect() {
        guard let text = urlField.text, let url = URL(string: text) else {
            SVProgressHUD.showError(withStatus: "请输入有效的 WS 地址")
            return
        }
        client.connect(url: url)
        SVProgressHUD.showSuccess(withStatus: "连接中...")
    }

    @objc private func sendOn() {
        let payload: [String: Any] = [
            "cmd": "onoff",
            "addr": "group/0xC123",
            "on": true
        ]
        client.send(json: payload)
    }

    @objc private func sendOff() {
        let payload: [String: Any] = [
            "cmd": "onoff",
            "addr": "group/0xC123",
            "on": false
        ]
        client.send(json: payload)
    }

    private func appendLog(_ t: String) {
        logView.text = (logView.text ?? "") + "\n" + t
        let range = NSRange(location: logView.text.count - 1, length: 1)
        logView.scrollRangeToVisible(range)
    }
}


