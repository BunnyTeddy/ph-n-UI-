#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <Wire.h>
#include <BH1750.h>
#include <ArduinoJson.h>
#include <SPIFFS.h>
#include <time.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include "config/wifi_config.h"
#include "config/firebase_config.h"

#define DHT_PIN 4
#define DHT_TYPE DHT22
#define FAN_PIN 26
#define PUMP_PIN 25
#define LIGHT_PIN 13
#define SOIL_PIN 34
#define CO2_PIN 35

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 25200, 60000);

unsigned long lastFirebaseSend = 0;
unsigned long lastHistorySave = 0;

// ====== SENSOR MANAGER ======
class SensorManager {
public:
    static void initialize() {
        Wire.begin();
        _dht.begin();
        _lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE);
    }
    static float getTemperature() { float t=_dht.readTemperature(); return isnan(t)?25:t; }
    static float getHumidity() { float h=_dht.readHumidity(); return isnan(h)?60:h; }
    static int getSoilMoisture() { return analogRead(SOIL_PIN); }
    static float getLightLevel() { return _lightMeter.readLightLevel(); }
    static int getCO2Level() { return analogRead(CO2_PIN); }
private:
    static DHT _dht;
    static BH1750 _lightMeter;
};
DHT SensorManager::_dht(DHT_PIN, DHT_TYPE);
BH1750 SensorManager::_lightMeter;

// ====== DEVICE MANAGER ======
class DeviceManager {
public:
    static void initialize() {
        pinMode(FAN_PIN, OUTPUT); pinMode(PUMP_PIN, OUTPUT); pinMode(LIGHT_PIN, OUTPUT);
        fanOff(); pumpOff(); lightOff();
    }
    static void fanOn(){digitalWrite(FAN_PIN,HIGH);_fan=true;}
    static void fanOff(){digitalWrite(FAN_PIN,LOW);_fan=false;}
    static void pumpOn(){digitalWrite(PUMP_PIN,HIGH);_pump=true;}
    static void pumpOff(){digitalWrite(PUMP_PIN,LOW);_pump=false;}
    static void lightOn(){digitalWrite(LIGHT_PIN,HIGH);_light=true;}
    static void lightOff(){digitalWrite(LIGHT_PIN,LOW);_light=false;}
    static bool fan(){return _fan;} static bool pump(){return _pump;} static bool light(){return _light;}
private:
    static bool _fan,_pump,_light;
};
bool DeviceManager::_fan=false; bool DeviceManager::_pump=false; bool DeviceManager::_light=false;

// ====== HISTORY MANAGER ======
class HistoryManager {
public:
    static void initialize(){ if(!SPIFFS.begin(true)) Serial.println("SPIFFS init failed"); }
    static void saveData(){
        if(millis()-lastHistorySave < 30000) return; // save mỗi 30s
        lastHistorySave = millis();

        File f=SPIFFS.open("/sensor_history.json",FILE_APPEND);
        if(!f) return;
        StaticJsonDocument<200> doc;
        doc["t"]=SensorManager::getTemperature();
        doc["h"]=SensorManager::getHumidity();
        doc["s"]=SensorManager::getSoilMoisture();
        doc["l"]=SensorManager::getLightLevel();
        doc["c"]=SensorManager::getCO2Level();
        doc["ts"]=millis();
        serializeJson(doc,f);
        f.println();
        f.close();
    }
};

// ====== AUTOMATION MANAGER ======
struct SensorThresholds {
  float tHigh=30,tLow=27; int sDry=4000,sWet=3000; int lDark=50,lBright=300; int cHigh=1000,cLow=400;
};
class AutomationManager {
public:
    static void initialize(){ 
      timeClient.begin(); 
      timeClient.update();
      _autoMode = true; // Mặc định là auto
    }
    static void update(){
        // Chỉ chạy khi autoMode = true
        if(!_autoMode) return; 
        
        // Logic tự động
        float temp=SensorManager::getTemperature();
        int soil=SensorManager::getSoilMoisture();
        float light=SensorManager::getLightLevel();
        int co2=SensorManager::getCO2Level();
        timeClient.update(); int hour=timeClient.getHours();

        // LIGHT
        if(hour>=6 && hour<18){
            if(light < _th.lDark) DeviceManager::lightOn();
            else if(light > _th.lBright) DeviceManager::lightOff();
        } else DeviceManager::lightOff();

        // TEMP + CO2
        if(temp > _th.tHigh || co2 > _th.cHigh) DeviceManager::fanOn();
        else if(temp < _th.tLow && co2 < _th.cHigh) DeviceManager::fanOff();

        // SOIL
        if(soil > _th.sDry) DeviceManager::pumpOn();
        else if(soil < _th.sWet) DeviceManager::pumpOff();

        HistoryManager::saveData();
    }
    
    // Các hàm để set/get trạng thái auto
    static bool isAutoMode(){ return _autoMode; }
    static void setAutoMode(bool mode){ _autoMode = mode; }
    
private:
    static SensorThresholds _th;
    static bool _autoMode; // Biến lưu trạng thái auto
};
SensorThresholds AutomationManager::_th;
bool AutomationManager::_autoMode;

// ====== FIREBASE MANAGER ======
class FirebaseManager {
public:
    static void initialize(){
        // URL để GỬI (POST) dữ liệu cảm biến
        _firebaseUrl = String(FIREBASE_URL) + "/sensorData.json?auth=" + String(FIREBASE_SECRET);
        
        // URL để NHẬN (GET) lệnh điều khiển
        _controlsUrl = String(FIREBASE_URL) + "/controls.json?auth=" + String(FIREBASE_SECRET);
        
        _client.setInsecure();
    }
    static void sendSensorData(){
        if(millis()-lastFirebaseSend < 10000) return; // gửi mỗi 10s
        lastFirebaseSend = millis();
        if(WiFi.status()!=WL_CONNECTED){ Serial.println("WiFi mất kết nối"); return; }

        StaticJsonDocument<400> doc;
        doc["temperature"]=SensorManager::getTemperature();
        doc["humidity"]=SensorManager::getHumidity();
        doc["soilMoisture"]=SensorManager::getSoilMoisture();
        doc["lightLevel"]=SensorManager::getLightLevel();
        doc["co2Level"]=SensorManager::getCO2Level();
        
        // Gửi cả trạng thái thiết bị và autoMode
        doc["fan"]=DeviceManager::fan(); 
        doc["pump"]=DeviceManager::pump();
        doc["light"]=DeviceManager::light();
        doc["autoMode"]=AutomationManager::isAutoMode();
        
        doc["timestamp"]=millis();

        String payload; serializeJson(doc,payload);

        _https.begin(_client, _firebaseUrl);
        _https.addHeader("Content-Type","application/json");
        int code=_https.POST(payload);

        if(code>0) Serial.printf("✅ Firebase sensor data sent: %d\n", code);
        else Serial.printf("❌ Firebase sensor error: %d\n", code);

        _https.end();
    }
    
    // HÀM QUAN TRỌNG: Kiểm tra lệnh điều khiển
    static void checkControls(){
        // Kiểm tra mỗi 500ms (0.5 giây) cho phản hồi nhanh
        if(millis() - lastControlCheck < 500) return; 
        lastControlCheck = millis();

        if(WiFi.status() != WL_CONNECTED) {
            Serial.println("WiFi not connected, skipping controls check");
            return;
        }

        _https.begin(_client, _controlsUrl);
        int code = _https.GET();

        if (code == 200) {
            String payload = _https.getString();
            Serial.println("Controls received: " + payload);

            StaticJsonDocument<200> doc;
            DeserializationError error = deserializeJson(doc, payload);

            if (!error) {
                // Lấy lệnh từ Firebase
                bool autoMode = doc["autoMode"] | true; // Mặc định là true nếu null
                bool fan = doc["fan"] | false;
                bool pump = doc["pump"] | false;
                bool light = doc["light"] | false;

                // 1. Cập nhật trạng thái AutoMode
                AutomationManager::setAutoMode(autoMode);

                // 2. Chỉ điều khiển bằng tay NẾU autoMode = false
                if (!autoMode) {
                    Serial.println("Manual mode: Applying controls...");
                    if (fan) DeviceManager::fanOn(); else DeviceManager::fanOff();
                    if (pump) DeviceManager::pumpOn(); else DeviceManager::pumpOff();
                    if (light) DeviceManager::lightOn(); else DeviceManager::lightOff();
                } else {
                    Serial.println("Auto mode active.");
                }
            } else {
                Serial.println("Failed to parse controls JSON");
            }
        } else {
            Serial.printf("❌ Firebase controls error: %d\n", code);
        }
        _https.end();
    }
private:
    static WiFiClientSecure _client;
    static HTTPClient _https;
    static String _firebaseUrl;
    static String _controlsUrl;
    static unsigned long lastControlCheck;
};
WiFiClientSecure FirebaseManager::_client;
HTTPClient FirebaseManager::_https;
String FirebaseManager::_firebaseUrl;
String FirebaseManager::_controlsUrl;
unsigned long FirebaseManager::lastControlCheck = 0;

// ====== MAIN ======
void setup(){
    Serial.begin(115200);
    WiFi.begin(WIFI_SSID,WIFI_PASSWORD);
    Serial.print("Đang kết nối WiFi");
    while(WiFi.status()!=WL_CONNECTED){ delay(500); Serial.print("."); }
    Serial.println("\nWiFi Connected: "+WiFi.localIP().toString());

    SensorManager::initialize();
    DeviceManager::initialize();
    HistoryManager::initialize();
    AutomationManager::initialize();
    FirebaseManager::initialize();
}

// ====== LOOP (NON-BLOCKING) ======
void loop(){
    // 1. Luôn kiểm tra lệnh điều khiển (non-blocking)
    FirebaseManager::checkControls();

    // 2. Chạy logic tự động (hàm này sẽ tự kiểm tra _autoMode)
    AutomationManager::update();
    
    // 3. Gửi dữ liệu cảm biến (non-blocking)
    FirebaseManager::sendSensorData();
    
    // KHÔNG DÙNG delay()
}
