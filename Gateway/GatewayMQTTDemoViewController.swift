//
//  GatewayMQTTDemoViewController.swift
//  AiPlanner
//
//  Zigbee 网关 MQTT Demo 控制器
//

import UIKit
import SVProgressHUD

final class GatewayMQTTDemoViewController: BaseViewController {
    private let client = GatewayMQTTClient()

    private let hostField = UITextField()
    private let portField = UITextField()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let gatewayIdField = UITextField()
    private let connectButton = UIButton(type: .system)
    private let logView = UITextView()
    private let onButton = UIButton(type: .system)
    private let offButton = UIButton(type: .system)
    private let statusButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Zigbee 网关 (MQTT)"
        view.backgroundColor = .white
        setupUI()
        wireEvents()
    }

    private func setupUI() {
        hostField.placeholder = "MQTT Broker (IP/域名)"
        hostField.borderStyle = .roundedRect
        hostField.text = "192.168.1.2"
        
        portField.placeholder = "端口"
        portField.borderStyle = .roundedRect
        portField.text = "1883"
        portField.keyboardType = .numberPad
        
        usernameField.placeholder = "用户名（可选）"
        usernameField.borderStyle = .roundedRect
        
        passwordField.placeholder = "密码（可选）"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        
        gatewayIdField.placeholder = "网关 ID"
        gatewayIdField.borderStyle = .roundedRect
        gatewayIdField.text = "gw1"

        connectButton.setTitle("连接", for: .normal)
        connectButton.backgroundColor = AiThemColor.app_tintColor
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.layer.cornerRadius = 8

        logView.isEditable = false
        logView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        logView.layer.cornerRadius = 8
        logView.font = .systemFont(ofSize: 12)

        onButton.setTitle("群组开 (group/0xC123)", for: .normal)
        onButton.backgroundColor = AiThemColor.app_tintColor
        onButton.setTitleColor(.white, for: .normal)
        onButton.layer.cornerRadius = 8

        offButton.setTitle("群组关 (group/0xC123)", for: .normal)
        offButton.backgroundColor = .systemGray
        offButton.setTitleColor(.white, for: .normal)
        offButton.layer.cornerRadius = 8

        statusButton.setTitle("订阅状态", for: .normal)
        statusButton.backgroundColor = .systemBlue
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.cornerRadius = 8

        [hostField, portField, usernameField, passwordField, gatewayIdField, connectButton, logView, onButton, offButton, statusButton].forEach { view.addSubview($0) }
        [hostField, portField, usernameField, passwordField, gatewayIdField, connectButton, logView, onButton, offButton, statusButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            hostField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            hostField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hostField.heightAnchor.constraint(equalToConstant: 44),

            portField.topAnchor.constraint(equalTo: hostField.bottomAnchor, constant: 8),
            portField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portField.widthAnchor.constraint(equalToConstant: 100),
            portField.heightAnchor.constraint(equalToConstant: 44),

            usernameField.topAnchor.constraint(equalTo: portField.bottomAnchor, constant: 8),
            usernameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usernameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            usernameField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 8),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            gatewayIdField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            gatewayIdField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gatewayIdField.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -8),
            gatewayIdField.heightAnchor.constraint(equalToConstant: 44),

            connectButton.centerYAnchor.constraint(equalTo: gatewayIdField.centerYAnchor),
            connectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            connectButton.widthAnchor.constraint(equalToConstant: 80),
            connectButton.heightAnchor.constraint(equalToConstant: 44),

            logView.topAnchor.constraint(equalTo: gatewayIdField.bottomAnchor, constant: 12),
            logView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logView.heightAnchor.constraint(equalToConstant: 200),

            onButton.topAnchor.constraint(equalTo: logView.bottomAnchor, constant: 12),
            onButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onButton.heightAnchor.constraint(equalToConstant: 50),

            offButton.topAnchor.constraint(equalTo: onButton.bottomAnchor, constant: 8),
            offButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            offButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            offButton.heightAnchor.constraint(equalToConstant: 50),

            statusButton.topAnchor.constraint(equalTo: offButton.bottomAnchor, constant: 8),
            statusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func wireEvents() {
        connectButton.addTarget(self, action: #selector(toggleConnect), for: .touchUpInside)
        onButton.addTarget(self, action: #selector(sendOn), for: .touchUpInside)
        offButton.addTarget(self, action: #selector(sendOff), for: .touchUpInside)
        statusButton.addTarget(self, action: #selector(subscribeStatus), for: .touchUpInside)

        client.onConnected = { [weak self] in
            self?.appendLog("✓ MQTT 已连接")
            SVProgressHUD.showSuccess(withStatus: "连接成功")
        }
        
        client.onDisconnected = { [weak self] error in
            self?.appendLog("✗ MQTT 已断开: \(error?.localizedDescription ?? "unknown")")
            SVProgressHUD.showError(withStatus: "连接断开")
        }
        
        client.onMessage = { [weak self] topic, message in
            self?.appendLog("📨 [\(topic)]: \(message)")
        }
        
        client.onLog = { [weak self] text in
            self?.appendLog(text)
        }
    }

    @objc private func toggleConnect() {
        guard let host = hostField.text, !host.isEmpty,
              let portText = portField.text, let port = UInt16(portText) else {
            SVProgressHUD.showError(withStatus: "请输入有效的地址和端口")
            return
        }
        
        let username = usernameField.text?.isEmpty == false ? usernameField.text : nil
        let password = passwordField.text?.isEmpty == false ? passwordField.text : nil
        
        SVProgressHUD.show(withStatus: "连接中...")
        client.connect(host: host, port: port, username: username, password: password, useTLS: false)
    }

    @objc private func sendOn() {
        guard let gwId = gatewayIdField.text, !gwId.isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入网关 ID")
            return
        }
        
        let command: [String: Any] = [
            "cmd": "onoff",
            "addr": "group/0xC123",
            "on": true,
            "msgId": UUID().uuidString.prefix(8)
        ]
        client.sendDeviceCommand(gatewayId: gwId, command: command)
        SVProgressHUD.showSuccess(withStatus: "已发送")
    }

    @objc private func sendOff() {
        guard let gwId = gatewayIdField.text, !gwId.isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入网关 ID")
            return
        }
        
        let command: [String: Any] = [
            "cmd": "onoff",
            "addr": "group/0xC123",
            "on": false,
            "msgId": UUID().uuidString.prefix(8)
        ]
        client.sendDeviceCommand(gatewayId: gwId, command: command)
        SVProgressHUD.showSuccess(withStatus: "已发送")
    }

    @objc private func subscribeStatus() {
        guard let gwId = gatewayIdField.text, !gwId.isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入网关 ID")
            return
        }
        
        client.subscribeDeviceStatus(gatewayId: gwId)
        SVProgressHUD.showSuccess(withStatus: "已订阅状态")
    }

    private func appendLog(_ t: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logView.text = (logView.text ?? "") + "\n[\(timestamp)] \(t)"
        let range = NSRange(location: logView.text.count - 1, length: 1)
        logView.scrollRangeToVisible(range)
    }
}
