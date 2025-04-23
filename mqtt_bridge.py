import paho.mqtt.client as mqtt
import ssl

# AWS IoT Core details
AWS_ENDPOINT = "a2vfty8at6hnbk-ats.iot.ap-south-1.amazonaws.com"
AWS_PORT = 8883
CA_PATH = "/home/KartikSakhuja/cert/AmazonRootCA1.pem"
CERT_PATH = "/home/KartikSakhuja/cert/device.crt"
KEY_PATH = "/home/KartikSakhuja/cert/private.key"
TOPIC = "sensor/data"

# Local broker details
LOCAL_BROKER = "localhost"
LOCAL_PORT = 1883

# AWS MQTT client
aws_client = mqtt.Client(client_id="raspiBridge")
aws_client.tls_set(
    ca_certs=CA_PATH,
    certfile=CERT_PATH,
    keyfile=KEY_PATH,
    tls_version=ssl.PROTOCOL_TLSv1_2
)
aws_client.connect(AWS_ENDPOINT, AWS_PORT)

# Local MQTT client
def on_connect_local(client, userdata, flags, rc):
    print("✅ Connected to local MQTT broker with code", rc)
    client.subscribe("sensor/data")

def on_message(client, userdata, msg):
    print(f"📤 Forwarding message to AWS IoT: {msg.payload.decode()}")
    aws_client.publish(TOPIC, msg.payload)

local_client = mqtt.Client(client_id="local_mqtt_client")
local_client.on_connect = on_connect_local
local_client.on_message = on_message
local_client.connect(LOCAL_BROKER, LOCAL_PORT, 60)

# Start both loops
local_client.loop_start()
aws_client.loop_start()

# Keep running
try:
    while True:
        pass
except KeyboardInterrupt:
    print("🛑 Exiting bridge...")
    local_client.loop_stop()
    aws_client.loop_stop()
    local_client.disconnect()
    aws_client.disconnect()
