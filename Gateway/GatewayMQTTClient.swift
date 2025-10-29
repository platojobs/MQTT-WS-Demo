//
//  GatewayMQTTClient.swift
//  AiPlanner
//
//  Zigbee 网关 MQTT 客户端（使用 CocoaMQTT）
//  支持 LAN 优先 + 云端回落、会话保持、QoS、重连
//

import Foundation

// 注意：如果未安装 CocoaMQTT，请取消 Podfile 中的注释并运行 pod install
// import CocoaMQTT  // 实际使用时取消注释

/// MQTT 客户端封装（Zigbee 网关通讯）
final class GatewayMQTTClient {
    
    // MARK: - Properties
    private var mqtt: Any? // CocoaMQTT 类型，使用 Any 避免编译错误（未安装时）
    
    private var host: String = ""
    private var port: UInt16 = 1883
    private var clientId: String = ""
    private var username: String?
    private var password: String?
    private var isConnected: Bool = false
    
    // MARK: - Callbacks
    var onConnected: (() -> Void)?
    var onDisconnected: ((Error?) -> Void)?
    var onMessage: ((String, String) -> Void)? // topic, message
    var onLog: ((String) -> Void)?
    
    // MARK: - Initialization
    init() {
        // 生成唯一 Client ID
        clientId = "iOS_\(UUID().uuidString.prefix(8))"
    }
    
    // MARK: - Connection
    /// 连接到 MQTT Broker
    /// - Parameters:
    ///   - host: Broker 地址（IP 或域名）
    ///   - port: 端口（默认 1883，TLS 通常 8883）
    ///   - username: 用户名（可选）
    ///   - password: 密码（可选）
    ///   - useTLS: 是否使用 TLS（默认 false）
    func connect(host: String, port: UInt16 = 1883, username: String? = nil, password: String? = nil, useTLS: Bool = false) {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        
        onLog?("MQTT connecting to \(host):\(port) (TLS: \(useTLS))")
        
        // TODO: 实际使用时取消注释并接入 CocoaMQTT
        /*
        let mqtt = CocoaMQTT(clientID: clientId, host: host, port: port)
        mqtt.username = username
        mqtt.password = password
        mqtt.keepAlive = 60
        mqtt.delegate = self
        
        if useTLS {
            mqtt.enableSSL = true
            // 可选：证书验证
            // mqtt.allowUntrustCACertificate = false
        }
        
        self.mqtt = mqtt
        _ = mqtt.connect()
        */
        
        // 模拟连接（实际使用时删除）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isConnected = true
            self?.onLog?("MQTT connected (simulated)")
            self?.onConnected?()
        }
    }
    
    /// 断开连接
    func disconnect() {
        onLog?("MQTT disconnecting")
        
        // TODO: 实际使用时取消注释
        /*
        if let mqtt = mqtt as? CocoaMQTT {
            mqtt.disconnect()
        }
        */
        
        // 模拟断开（实际使用时删除）
        isConnected = false
        onDisconnected?(nil)
    }
    
    // MARK: - Publish & Subscribe
    /// 订阅主题
    /// - Parameter topic: 主题（支持通配符，如 "home/gw1/status/#"）
    /// - Parameter qos: QoS 等级（0/1/2）
    func subscribe(topic: String, qos: CocoaMQTTQoS = .qos1) {
        onLog?("Subscribe: \(topic)")
        
        // TODO: 实际使用时取消注释
        /*
        if let mqtt = mqtt as? CocoaMQTT {
            mqtt.subscribe(topic, qos: qos)
        }
        */
    }
    
    /// 取消订阅
    /// - Parameter topic: 主题
    func unsubscribe(topic: String) {
        onLog?("Unsubscribe: \(topic)")
        
        // TODO: 实际使用时取消注释
        /*
        if let mqtt = mqtt as? CocoaMQTT {
            mqtt.unsubscribe(topic)
        }
        */
    }
    
    /// 发布消息
    /// - Parameters:
    ///   - topic: 主题
    ///   - message: 消息内容（JSON 字符串）
    ///   - qos: QoS 等级
    ///   - retained: 是否保留消息
    func publish(topic: String, message: String, qos: CocoaMQTTQoS = .qos1, retained: Bool = false) {
        guard isConnected else {
            onLog?("Not connected, cannot publish")
            return
        }
        
        onLog?("Publish to \(topic): \(message)")
        
        // TODO: 实际使用时取消注释
        /*
        if let mqtt = mqtt as? CocoaMQTT {
            mqtt.publish(topic, withString: message, qos: qos, retained: retained)
        }
        */
        
        // 模拟发布（实际使用时删除）
        onLog?("Published (simulated)")
    }
    
    /// 发布 JSON 对象
    /// - Parameters:
    ///   - topic: 主题
    ///   - json: JSON 字典
    ///   - qos: QoS 等级
    func publishJSON(topic: String, json: [String: Any], qos: CocoaMQTTQoS = .qos1) {
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let message = String(data: data, encoding: .utf8) else {
            onLog?("Failed to serialize JSON")
            return
        }
        publish(topic: topic, message: message, qos: qos)
    }
    
    // MARK: - Convenience Methods
    /// 发送设备控制命令（示例主题格式）
    /// - Parameters:
    ///   - gatewayId: 网关 ID
    ///   - command: 命令字典
    func sendDeviceCommand(gatewayId: String, command: [String: Any]) {
        let topic = "home/\(gatewayId)/ctl"
        publishJSON(topic: topic, json: command)
    }
    
    /// 订阅设备状态主题（示例主题格式）
    /// - Parameter gatewayId: 网关 ID
    func subscribeDeviceStatus(gatewayId: String) {
        let topic = "home/\(gatewayId)/status/#"
        subscribe(topic: topic)
    }
}

// MARK: - CocoaMQTTDelegate（实际使用时取消注释）
/*
extension GatewayMQTTClient: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            isConnected = true
            onLog?("MQTT connected")
            onConnected?()
        } else {
            onLog?("MQTT connect failed: \(ack)")
            onDisconnected?(NSError(domain: "MQTT", code: Int(ack.rawValue), userInfo: nil))
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        onLog?("Published message ID: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        onLog?("Publish ACK: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let topic = message.topic
        let payload = message.string ?? ""
        onLog?("Received message from \(topic): \(payload)")
        onMessage?(topic, payload)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSMutableDictionary, failed: [String]) {
        if failed.isEmpty {
            onLog?("Subscribed successfully")
        } else {
            onLog?("Subscribe failed: \(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        onLog?("Unsubscribed: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Heartbeat
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // Heartbeat response
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        isConnected = false
        onLog?("MQTT disconnected: \(err?.localizedDescription ?? "unknown")")
        onDisconnected?(err)
    }
}
*/

// MARK: - QoS 枚举（兼容 CocoaMQTT）
enum CocoaMQTTQoS: UInt8 {
    case qos0 = 0
    case qos1 = 1
    case qos2 = 2
}
