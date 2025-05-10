#include <ESP8266WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Mitadtu_Staff";   
const char* password = "Mitadtu@2016";
const char* mqttServer = "172.25.12.252";  // Replace with Raspberry Pi IP
const int mqttPort = 1883;
const char* clientID = "NodeMCU_4"; // Unique identifier for second NodeMCU

WiFiClient espClient;
PubSubClient client(espClient);

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("[NodeMCU_4] Message received on topic: ");
  Serial.println(topic);
  
  Serial.print("[NodeMCU_4] Data: ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("[NodeMCU_4] Connecting to WiFi...");
  }
  Serial.println("[NodeMCU_4] Connected to WiFi");

  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);

  while (!client.connected()) {
    Serial.println("[NodeMCU_4] Connecting to MQTT...");
    if (client.connect(clientID)) {
      Serial.println("[NodeMCU_4] Connected to MQTT");
      client.subscribe("sensor/control");
    } else {
      Serial.print("[NodeMCU_4] Failed, state: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    while (!client.connect(clientID)) {
      Serial.println("[NodeMCU_4] Reconnecting to MQTT...");
      delay(2000);
    }
  }

  int temperature = random(25, 35);
  int humidity = random(50, 70);

  // Label data for differentiation
  String data = "[NodeMCU_4] Temp: " + String(temperature) + "°C, Humidity: " + String(humidity) + "%";
  
  Serial.println(data); // Print labeled data
  client.publish("sensor/data", data.c_str());

  client.loop();
  delay(5000);
}
