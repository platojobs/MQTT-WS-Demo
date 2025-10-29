//
//  GatewayMQClient.swift
//  AiPlanner
//
//  Zigbee 网关 Demo：基于 WebSocket 的轻量示意客户端
//  实际项目可替换为 MQTT（如 CocoaMQTT）或厂商 SDK
//

import Foundation

final class GatewayMQClient {
    private var ws: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)

    var onMessage: ((String) -> Void)?
    var onLog: ((String) -> Void)?

    func connect(url: URL) {
        ws = session.webSocketTask(with: url)
        ws?.resume()
        onLog?("WebSocket connecting: \(url.absoluteString)")
        receiveLoop()
    }

    func disconnect() {
        ws?.cancel(with: .goingAway, reason: nil)
        onLog?("WebSocket disconnected")
    }

    func send(json: [String: Any]) {
        guard let ws else { return }
        let data = try? JSONSerialization.data(withJSONObject: json)
        let text = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        ws.send(.string(text)) { [weak self] error in
            if let e = error { self?.onLog?("Send error: \(e.localizedDescription)") }
            else { self?.onLog?("Sent: \(text)") }
        }
    }

    private func receiveLoop() {
        ws?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let e):
                self.onLog?("Receive error: \(e.localizedDescription)")
            case .success(let msg):
                switch msg {
                case .string(let t):
                    self.onMessage?(t)
                    self.onLog?("Recv: \(t)")
                case .data(let d):
                    let t = String(data: d, encoding: .utf8) ?? "<bin>"
                    self.onMessage?(t)
                    self.onLog?("Recv bin: \(t)")
                @unknown default:
                    break
                }
            }
            self.receiveLoop()
        }
    }
}


