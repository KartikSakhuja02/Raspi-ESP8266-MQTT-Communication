#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

// DHT11 settings
#define DHTPIN D4       // GPIO2
#define DHTTYPE DHT11   // DHT11 sensor

DHT dht(DHTPIN, DHTTYPE);

// WiFi & MQTT credentials
const char* ssid = "iQOO Neo7";   
const char* password = "kartik02";
const char* mqttServer = "192.168.247.135";  // Raspberry Pi IP
const int mqttPort = 1883;
const char* clientID = "NodeMCU"; // Unique ID

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(115200);
  dht.begin();

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("[NodeMCU] Connecting to WiFi...");
  }
  Serial.println("[NodeMCU] Connected to WiFi");

  client.setServer(mqttServer, mqttPort);
  client.setCallback([](char* topic, byte* payload, unsigned int length) {
    Serial.print("[NodeMCU] Message received on topic: ");
    Serial.println(topic);
  });

  while (!client.connected()) {
    Serial.println("[NodeMCU] Connecting to MQTT...");
    if (client.connect(clientID)) {
      Serial.println("[NodeMCU] Connected to MQTT");
      client.subscribe("sensor/control");
    } else {
      Serial.print("[NodeMCU] MQTT Failed, State: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    while (!client.connect(clientID)) {
      Serial.println("[NodeMCU] Reconnecting to MQTT...");
      delay(2000);
    }
  }

  // Read DHT11 values
  float temperature = dht.readTemperature();  // °C
  float humidity = dht.readHumidity();        // %

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("[ERROR] Failed to read from DHT11 sensor!");
    return;
  }

  // Round to 1 decimal place for consistent formatting
  temperature = roundf(temperature * 10) / 10.0;
  humidity = roundf(humidity * 10) / 10.0;

  Serial.print("Temperature: ");
  Serial.print(temperature, 1);
  Serial.println(" °C");

  Serial.print("Humidity: ");
  Serial.print(humidity, 1);
  Serial.println(" %");

  String data = "{\"temperature\": " + String(temperature, 1) +
                ", \"humidity\": " + String(humidity, 1) + "}";

  client.publish("sensor/data", data.c_str());
  client.loop();

  delay(1000);  // 1-second delay
}
