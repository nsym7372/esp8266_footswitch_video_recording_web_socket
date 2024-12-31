#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>
#include "config.h"

const int switchPin = 2;
static int previousSensorState = HIGH;

unsigned long lastUpdated = 0; // 最後にデバウンス処理を行った時間
unsigned long debounceDelay = 1000;   // デバウンス間隔 (ミリ秒)

WebSocketsServer webSocket(81);

void setup() {
  Serial.begin(115200);
  pinMode(switchPin, INPUT_PULLUP);

  initNetwork();
  webSocket.begin();
  Serial.println("WebSocket server started");
}

void loop() {
  webSocket.loop();
  bool sensorState = digitalRead(switchPin);
  // 状態が変わったときだけ処理
  if(sensorState == LOW && previousSensorState == HIGH){
      if(millis() - lastUpdated < debounceDelay){
        return;
      }

      Serial.println("PRESSED");
      webSocket.broadcastTXT("PRESSED");

      lastUpdated = millis();
  }
  previousSensorState = sensorState; // 状態を更新
}

void initNetwork() {
  IPAddress local_IP(192, 168, 179, 10);
  IPAddress gateway(192, 168, 179, 1);
  IPAddress subnet(255, 255, 255, 0);

  WiFi.begin(CONF_SSID, CONF_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

