# Zigbee 网关 MQTT Demo

本 Demo 演示如何使用 MQTT 协议与 Zigbee 网关通信，支持 QoS、会话保持、自动重连等功能。

## 安装依赖

在 `Podfile` 中取消注释：

```ruby
pod 'CocoaMQTT', '~> 2.0'
```

然后运行：

```bash
pod install
```

## 使用方法

1. **打开 Demo**：创建 `GatewayMQTTDemoViewController` 实例并 push
2. **配置连接**：
   - MQTT Broker 地址（如 `192.168.1.2` 或 `mqtt.example.com`）
   - 端口（默认 1883，TLS 通常 8883）
   - 用户名/密码（如果 Broker 需要认证）
   - 网关 ID（用于构建主题）
3. **连接**：点击"连接"按钮
4. **发送命令**：点击"群组开/关"发送控制命令
5. **订阅状态**：点击"订阅状态"接收设备状态更新

## 主题格式

- **控制主题**：`home/{gatewayId}/ctl`
- **状态主题**：`home/{gatewayId}/status/#`（支持通配符）

## 消息格式示例

### 控制命令
```json
{
  "cmd": "onoff",
  "addr": "group/0xC123",
  "on": true,
  "msgId": "abc12345"
}
```

### 状态回报
```json
{
  "type": "status",
  "addr": "0x0005",
  "on": true,
  "ts": 1234567890
}
```

## 实际集成步骤

1. **取消注释真实代码**：
   - 在 `GatewayMQTTClient.swift` 中取消所有 `import CocoaMQTT` 和 CocoaMQTT 相关代码的注释
   - 删除模拟连接/发布的代码

2. **实现 LAN 优先**：
   - 使用 Bonjour 发现局域网内的 MQTT Broker
   - 优先连接局域网 Broker，失败则连接云端 Broker

3. **调整协议**：
   - 根据实际网关协议调整主题格式
   - 根据实际消息格式调整 JSON 结构

4. **安全配置**：
   - 如需 TLS，设置 `useTLS: true`
   - 配置证书验证（如需要）

## 特性

- ✅ QoS 0/1/2 消息等级
- ✅ 会话保持（Clean Session）
- ✅ 自动重连
- ✅ 心跳保活（Keep Alive）
- ✅ 主题订阅（支持通配符）
- ✅ TLS 支持
- ✅ 命令去重（msgId）

## 注意事项

- 当前代码包含模拟逻辑，实际使用时需要替换为真实的 CocoaMQTT 调用
- 建议实现 LAN 优先策略，降低延迟和云端带宽消耗
- 建议为每条命令添加 `msgId`，网关端做去重处理
- 长时间运行建议实现后台保活机制
