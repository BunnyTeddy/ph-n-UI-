# Đóng góp của Nguyễn Anh Tiến

## Nhiệm vụ được phân công

### 3. IoT - Phần cứng, Firmware & Tích hợp App

#### 3.1. Xây dựng Module phần cứng IoT
- **Mô tả**: Lắp ráp ESP32, cảm biến, máy bơm
- **Thư mục**: `firmware/`
- **Hardware Components**:
  - ESP32 DevKit
  - Cảm biến độ ẩm đất (Capacitive Soil Moisture Sensor)
  - Cảm biến nhiệt độ (DHT11/DHT22)
  - Module Relay (cho máy bơm)
  - Máy bơm nước mini

#### 3.2. Lập trình Firmware cho ESP32
- **Thư mục**: `firmware/src/`
- **Files**:
  - `main.cpp` - Main logic với SensorManager, DeviceManager, AutomationManager, FirebaseManager
  - `config/wifi_config.h` - WiFi credentials (gitignored)
  - `config/firebase_config.h` - Firebase credentials (gitignored)
  - **Chức năng**: Đọc cảm biến (DHT22, soil, light, CO2) và gửi dữ liệu lên Firebase Realtime Database

#### 3.3. Nhận lệnh điều khiển từ Firebase
- **Thư mục**: `firmware/src/`
- **Files**:
  - `main.cpp` - Integrated control logic
  - **Chức năng**: ESP32 lắng nghe lệnh từ Firebase và điều khiển relay (fan, pump, light) với auto mode

#### 3.4. Trang Smart Greenhouse Control
- **Thư mục**: `mobile_app/lib/features/iot/screens/`
- **Screens**:
  - `iot_home_screen.dart` - Smart Greenhouse control panel
  - `sensor_chart_screen.dart` - Biểu đồ lịch sử sensor với filtering
- **Features**:
  - Real-time sensor gauges (temperature, humidity, soil moisture, light, CO2)
  - Control tiles (fan, pump, light, auto mode)
  - Chart với time window selection (1h, 24h, 30d, 12m)

#### 3.5. Tích hợp Firebase Realtime Database
- **Thư mục**: `mobile_app/lib/`
- **Provider**: `providers/iot_provider.dart` - Real-time listener cho sensorData và controls
- **Dependencies**: 
  - `firebase_database: ^10.5.6`
  - `fl_chart: ^0.68.0`
- **Navigation**: Quick action button "IoT" trên Home screen

## Công việc đã hoàn thành

### Sprint 1 - Hardware
- [x] Mua và kiểm tra linh kiện
- [x] Lắp ráp mạch ESP32 với cảm biến
- [x] Test cảm biến độ ẩm đất
- [x] Test cảm biến nhiệt độ
- [x] Lắp ráp module relay với máy bơm

### Sprint 2 - Firmware cơ bản
- [x] Setup PlatformIO project
- [x] Implement soil_moisture_sensor.cpp
- [x] Implement temperature_sensor.cpp
- [x] Test đọc dữ liệu từ cảm biến
- [x] Serial monitor debugging

### Sprint 3 - Firebase Integration
- [x] Config WiFi connection
- [x] Setup Firebase ESP Client library
- [x] Implement firebase_client.cpp
- [x] Gửi dữ liệu sensor lên Firebase
- [x] Test real-time data sync

### Sprint 4 - Điều khiển
- [x] Implement relay_controller.cpp
- [x] Lắng nghe lệnh từ Firebase
- [x] Test điều khiển relay từ Firebase Console
- [x] Implement auto-off timer cho máy bơm

### Sprint 5 - App Integration
- [x] Tạo iot_home_screen.dart
- [x] Implement real-time data display
- [x] Tạo sensor_chart_screen.dart với fl_chart
- [x] Test hiển thị dữ liệu real-time

### Sprint 6 - Control Features
- [x] Implement control buttons in UI
- [x] Tạo iot_provider.dart
- [x] Implement iot_provider.dart
- [x] Test điều khiển từ app
- [x] Final integration testing

## Hardware Schematic

```
ESP32 Pin Connections:
- GPIO 34: Soil Moisture Sensor (Analog)
- GPIO 4:  DHT22 Data Pin
- GPIO 5:  Relay Control (Digital)
- 3.3V:    Sensor VCC
- GND:     Common Ground
```

## Firmware Architecture

```cpp
// Main Loop Flow:
1. Read sensor data every 5 seconds
2. Send data to Firebase
3. Check for control commands
4. Execute relay control if commanded
5. Update status back to Firebase
```

## Firebase Database Structure (IoT)

```
iot_data/
  {plantId}/
    sensor_readings/
      {timestamp}/
        - temperature
        - soilMoisture
        - humidity
    
    control/
      - pumpState (on/off)
      - lastCommand
      - autoMode (true/false)
```

## Screenshots

_Ảnh hardware setup, mạch điện, app IoT screens_

## Demo Video

_Video demo hardware hoạt động, điều khiển từ app_

## Git Commits

_Liệt kê các commit cho firmware và app_

## Pull Requests

_Link đến các PR_

## Ghi chú

_Các vấn đề về hardware, debugging, WiFi stability, power consumption_








