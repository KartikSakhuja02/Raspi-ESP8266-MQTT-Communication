import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final client = MqttServerClient('192.168.21.135', '');
  bool isConnected = false;

  Function(Map<String, dynamic>)? onMessageReceived;

  Future<void> connect() async {
    client.port = 1883;
    client.logging(on: true);  // Enable logging for debugging
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillQos(MqttQos.atLeastOnce)
        .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('Connected to MQTT Broker');
        isConnected = true;
        // Only subscribe if connected
        client.subscribe('sensor/data', MqttQos.atLeastOnce);
        
        // Set up the message handler
        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final payload = (c[0].payload as MqttPublishMessage).payload.message;
          final message = String.fromCharCodes(payload);
          print('Received: $message');
          
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            onMessageReceived?.call(data);
          } catch (e) {
            print('Error parsing message: $e');
          }
        });
      } else {
        print('Connection failed - disconnecting');
        client.disconnect();
      }
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void onDisconnected() {
    print('Disconnected');
    isConnected = false;
  }

  void onConnected() {
    print('Connected');
    isConnected = true;
  }

  void disconnect() {
    client.disconnect();
  }
}
