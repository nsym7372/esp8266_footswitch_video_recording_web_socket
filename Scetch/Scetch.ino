#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>

const char* ssid = "hogefuga";
const char* password = "hogepiyo";

// 固定IP
IPAddress local_IP(192, 168, 179, 10);
IPAddress gateway(192, 168, 179, 1);
IPAddress subnet(255, 255, 255, 0);

const int switchPin = 2;
bool lastSwitchState = HIGH;

unsigned long lastUpdated = 0; // 最後にデバウンス処理を行った時間
unsigned long debounceDelay = 50;   // デバウンス間隔 (ミリ秒)

WebSocketsServer webSocket(81);          // WebSocketサーバーをポート81で作成

void setup() {
  Serial.begin(115200);
  pinMode(switchPin, INPUT_PULLUP);

  if (!WiFi.config(local_IP, gateway, subnet)) {
    Serial.println("Failed to configure static IP");
  }

  // Wi-Fi接続
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  // WebSocketサーバー開始
  webSocket.begin();
  Serial.println("WebSocket server started");
}

void loop() {
  webSocket.loop();

  bool currentSwitchState = digitalRead(switchPin);
  // Serial.println("switchState: " + switchState);

  if (currentSwitchState != lastSwitchState) {  
    if(millis() - lastUpdated < debounceDelay){
      return;
    }
    lastUpdated = millis();

    lastSwitchState = currentSwitchState; // 状態を更新


    // スイッチが押された場合のみ通知
    if (currentSwitchState == LOW) {
      Serial.println("PRESSED");
      webSocket.broadcastTXT("PRESSED");
    }
  }
}

