# 📋 HƯỚNG DẪN TÍCH HỢP CODE CỦA HOÀNG VÀO PROJECT CHÍNH

> **Người thực hiện:** Hoàng hoặc Tech Lead  
> **Thời gian ước tính:** 2-3 giờ  
> **Mức độ:** Trung bình đến Khó

---

## 🎯 TỔNG QUAN

Code của Hoàng bao gồm:
- ✅ Statistics Screen (biểu đồ & thống kê)
- ✅ Notification System (FCM + Local Notifications)
- ✅ Sensor Monitoring (lắng nghe Firestore real-time)

**Vấn đề:** Code hiện tại nằm ở folder riêng và chưa integrate vào app chính.

---

## ⚠️ TRƯỚC KHI BẮT ĐẦU

### ✅ Checklist cần chuẩn bị:

1. **Backup code hiện tại:**
   ```bash
   git add .
   git commit -m "Before integrating Hoang's code"
   git branch backup-before-hoang-integration
   ```

2. **Đảm bảo Firebase đã setup:**
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - Firebase Console đã enable FCM

3. **Test app hiện tại chạy được:**
   ```bash
   cd mobile_app
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📝 BƯỚC 1: FIX CRITICAL BUGS TRONG CODE CỦA HOÀNG

### 🔧 **1.1. Fix Android Icon Path**

**File:** `providers/notification_provider.dart`

**Tìm (dòng ~114):**
```dart
const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('app_icon');  // ❌ SAI
```

**Đổi thành:**
```dart
const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');  // ✅ ĐÚNG
```

---

### 🔧 **1.2. Fix Activity Type Key**

**File:** `features/statistics/screens/statistics_screen.dart`

**Tìm (dòng ~313):**
```dart
final activityDetails = {
  'watering': {'icon': Icons.water_drop, 'color': Colors.blue},
  'fertilizing': {'icon': Icons.grass, 'color': Colors.green},
  'pruning': {'icon': Icons.content_cut, 'color': Colors.orange},
  'observing': {'icon': Icons.visibility, 'color': Colors.purple},  // ❌ SAI
  'unknown': {'icon': Icons.help_outline, 'color': Colors.grey},
};
```

**Đổi thành:**
```dart
final activityDetails = {
  'watering': {'icon': Icons.water_drop, 'color': Colors.blue},
  'fertilizing': {'icon': Icons.grass, 'color': Colors.green},
  'pruning': {'icon': Icons.content_cut, 'color': Colors.orange},
  'observation': {'icon': Icons.visibility, 'color': Colors.purple},  // ✅ ĐÚNG
  'unknown': {'icon': Icons.help_outline, 'color': Colors.grey},
};
```

**Lý do:** Model `DiaryEntryModel` dùng `observation` chứ không phải `observing`.

---

## 📝 BƯỚC 2: THỐNG NHẤT DATA STRUCTURE

### 🔍 **Vấn đề:**

Code có **2 nơi khác nhau** để lưu diary entries:

1. **DiaryProvider (code cũ):** `diary_entries` (root collection)
   ```
   diary_entries/
   ├── entry1 (plantId: "plant_123")
   ├── entry2 (plantId: "plant_123")
   └── entry3 (plantId: "plant_456")
   ```

2. **StatisticsService (code Hoàng):** `plants/{plantId}/diaries` (subcollection)
   ```
   plants/
   └── plant_123/
       └── diaries/
           ├── entry1
           └── entry2
   ```

### ✅ **Giải pháp: CHỌN 1 TRONG 2**

#### **Option A: Dùng Root Collection (Đề xuất - Dễ hơn)**

**Ưu điểm:**
- ✅ Không cần migration data
- ✅ Query dễ dàng hơn (không cần biết plantId trước)
- ✅ Code ít thay đổi hơn

**File cần sửa:** `features/statistics/services/statistics_service.dart`

**Đổi TẤT CẢ query từ:**
```dart
await _firestore
    .collection('plants')
    .doc(plantId)
    .collection('diaries')  // ❌ Sai
```

**Thành:**
```dart
await _firestore
    .collection('diary_entries')  // ✅ Đúng
    .where('plantId', isEqualTo: plantId)
```

**Các hàm cần sửa:**
1. `getSummaryData()` - dòng ~34
2. `getCareHistoryChartData()` - dòng ~73
3. `getActivityBreakdown()` - dòng ~106

---

#### **Option B: Dùng Subcollection (Cần migration)**

**Ưu điểm:**
- ✅ Data structure rõ ràng hơn
- ✅ Dễ xóa cây và toàn bộ diaries của nó

**Nhược điểm:**
- ❌ Phải migrate toàn bộ data hiện tại
- ❌ Code DiaryProvider phải viết lại

**File cần sửa:** `providers/diary_provider.dart`

Đổi tất cả `diary_entries` thành `plants/{plantId}/diaries`.

---

### 💡 **KHUYẾN NGHỊ: DÙNG OPTION A**

**Lý do:**
- Ít rủi ro hơn
- Code đã có sẵn cho root collection
- Không mất data

---

## 📝 BƯỚC 3: COPY FILES VÀO PROJECT CHÍNH

### 📂 **3.1. Kiểm tra cấu trúc thư mục**

```bash
cd /Users/banghoang/Mobile\ App/mobile_app
```

**Cấu trúc hiện tại:**
```
mobile_app/lib/
├── features/
│   ├── statistics/          ✅ Đã có!
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
├── providers/
│   └── notification_provider.dart  ✅ Đã có!
└── main.dart
```

### ✅ **Kiểm tra files đã có:**

Chạy lệnh:
```bash
ls -la mobile_app/lib/features/statistics/
ls -la mobile_app/lib/providers/notification_provider.dart
```

**Nếu CHƯA CÓ:** Copy từ folder `Ung-Dung-Di-Dong-master`:
```bash
# Copy statistics feature
cp -r "Ung-Dung-Di-Dong-master/Mobile App/mobile_app/lib/features/statistics/" \
      "mobile_app/lib/features/statistics/"

# Copy notification provider
cp "Ung-Dung-Di-Dong-master/Mobile App/mobile_app/lib/providers/notification_provider.dart" \
   "mobile_app/lib/providers/notification_provider.dart"
```

---

## 📝 BƯỚC 4: UPDATE PUBSPEC.YAML

### ✅ **4.1. Kiểm tra dependencies**

**File:** `mobile_app/pubspec.yaml`

**Cần có:**
```yaml
dependencies:
  # ... existing dependencies ...
  
  # Charts (Hoàng cần)
  fl_chart: ^0.68.0
  
  # Notifications (Hoàng cần)
  flutter_local_notifications: ^17.2.1
  
  # Firebase Messaging (Hoàng cần)
  firebase_messaging: ^16.0.3  # Đã có rồi!
```

### 🔧 **4.2. Nếu thiếu, thêm vào:**

```bash
flutter pub add flutter_local_notifications
```

Sau đó:
```bash
flutter pub get
```

---

## 📝 BƯỚC 5: KHỞI TẠO NOTIFICATIONPROVIDER

### 🔧 **5.1. Update app.dart**

**File:** `mobile_app/lib/app.dart`

**Đổi từ StatelessWidget → StatefulWidget:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';  // ✅ Thêm import

class PlantCareApp extends StatefulWidget {  // ✅ Đổi thành StatefulWidget
  const PlantCareApp({super.key});

  @override
  State<PlantCareApp> createState() => _PlantCareAppState();
}

class _PlantCareAppState extends State<PlantCareApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Khởi tạo NotificationProvider sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = 
          Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'Plant Care App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.dev,  // Hoặc route bạn muốn
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
```

---

## 📝 BƯỚC 6: FIX ROUTES CHO STATISTICS

### 🔧 **6.1. Update app_routes.dart**

**File:** `mobile_app/lib/core/routes/app_routes.dart`

**Tìm (dòng ~102):**
```dart
// Statistics
case statistics:
  return MaterialPageRoute(builder: (_) => const StatisticsScreen());  // ❌ Thiếu plantId
```

**Đổi thành:**
```dart
// Statistics
case statistics:
  final plantId = settings.arguments as String?;
  if (plantId == null) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Cần chọn cây trước!')),
      ),
    );
  }
  return MaterialPageRoute(
    builder: (_) => StatisticsScreen(plantId: plantId),  // ✅ Truyền plantId
  );
```

---

## 📝 BƯỚC 7: INTEGRATE VÀO PLANT DETAIL SCREEN

### 🔧 **7.1. Update PlantDetailIotScreen**

**File:** `mobile_app/lib/features/iot/screens/plant_detail_iot_screen.dart`

**Thêm import:**
```dart
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
```

**Thêm vào initState:**
```dart
@override
void initState() {
  super.initState();
  
  // ✅ Bắt đầu lắng nghe sensor cho cây này
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<NotificationProvider>(context, listen: false)
        .startSensorListening(plantId: widget.plantId);
  });
  
  // ... existing code ...
}
```

**Thêm vào dispose:**
```dart
@override
void dispose() {
  // ✅ Dừng lắng nghe khi rời khỏi màn hình
  Provider.of<NotificationProvider>(context, listen: false)
      .stopSensorListening();
  
  super.dispose();
}
```

**Thêm button "Thống kê" vào UI:**
```dart
// Trong phần actions của AppBar hoặc body
ElevatedButton.icon(
  icon: const Icon(Icons.bar_chart),
  label: const Text('Xem thống kê'),
  onPressed: () {
    Navigator.pushNamed(
      context, 
      AppRoutes.statistics,
      arguments: widget.plantId,  // Truyền plantId
    );
  },
)
```

---

## 📝 BƯỚC 8: SETUP ANDROID NOTIFICATIONS

### 🔧 **8.1. Update AndroidManifest.xml**

**File:** `mobile_app/android/app/src/main/AndroidManifest.xml`

**Thêm permissions (nếu chưa có):**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- ✅ Thêm permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <application ...>
        <!-- ... existing code ... -->
        
        <!-- ✅ Thêm notification channel (Android 8.0+) -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="plant_alerts" />
    </application>
</manifest>
```

---

## 📝 BƯỚC 9: TEST INTEGRATION

### ✅ **9.1. Clean & Rebuild**

```bash
cd mobile_app
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### ✅ **9.2. Test Checklist**

1. **App khởi động thành công?**
   - [ ] Không crash
   - [ ] Không có lỗi import
   - [ ] NotificationProvider initialize thành công

2. **Statistics Screen hoạt động?**
   - [ ] Vào plant detail
   - [ ] Nhấn "Xem thống kê"
   - [ ] Màn hình statistics hiển thị
   - [ ] Biểu đồ load được (hoặc "Không có dữ liệu")

3. **Notifications hoạt động?**
   - [ ] Permission được yêu cầu (iOS)
   - [ ] FCM token được lưu vào Firestore
   - [ ] Sensor listening bắt đầu khi vào plant detail

4. **Test với mock data:**
   - [ ] Thêm diary entry với activityType = "watering"
   - [ ] Refresh statistics screen
   - [ ] Kiểm tra biểu đồ có cập nhật không

---

## 📝 BƯỚC 10: SỬA LỖI DATA STRUCTURE (QUAN TRỌNG!)

### 🔧 **Option A được chọn - Dùng Root Collection**

**File:** `mobile_app/lib/features/statistics/services/statistics_service.dart`

**Tìm và sửa 3 hàm:**

#### **Hàm 1: getSummaryData()**
```dart
Future<Map<String, int>> getSummaryData({
  required String plantId,
  required String period,
}) async {
  final now = DateTime.now();
  final startDate = _getStartDate(now, period);

  try {
    // ✅ ĐỔI QUERY
    final querySnapshot = await _firestore
        .collection('diary_entries')  // Đổi từ 'plants'
        .where('plantId', isEqualTo: plantId)  // Thêm where
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // ... rest of code stays the same ...
  }
}
```

#### **Hàm 2: getCareHistoryChartData()**
```dart
Future<Map<String, double>> getCareHistoryChartData({
  required String plantId,
  required String period,
}) async {
  final now = DateTime.now();
  final startDate = _getStartDate(now, period);

  try {
    // ✅ ĐỔI QUERY
    final querySnapshot = await _firestore
        .collection('diary_entries')  // Đổi từ 'plants'
        .where('plantId', isEqualTo: plantId)  // Thêm where
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('timestamp')
        .get();

    // ... rest of code stays the same ...
  }
}
```

#### **Hàm 3: getActivityBreakdown()**
```dart
Future<Map<String, double>> getActivityBreakdown({
  required String plantId,
  required String period,
}) async {
  final now = DateTime.now();
  final startDate = _getStartDate(now, period);

  try {
    // ✅ ĐỔI QUERY
    final querySnapshot = await _firestore
        .collection('diary_entries')  // Đổi từ 'plants'
        .where('plantId', isEqualTo: plantId)  // Thêm where
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // ... rest of code stays the same ...
  }
}
```

---

## 📝 BƯỚC 11: KIỂM TRA VÀ FIX TIMESTAMP FIELD

### ⚠️ **Vấn đề tiềm ẩn:**

DiaryProvider lưu:
```dart
entryData['createdAt'] = DateTime.now().toIso8601String();  // String!
```

Nhưng StatisticsService query:
```dart
.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))  // Timestamp!
```

### 🔧 **Giải pháp:**

**File:** `mobile_app/lib/providers/diary_provider.dart`

**Tìm (dòng ~56):**
```dart
entryData['createdAt'] = DateTime.now().toIso8601String();
```

**Đổi thành:**
```dart
entryData['timestamp'] = FieldValue.serverTimestamp();  // ✅ Dùng Timestamp
entryData['createdAt'] = DateTime.now().toIso8601String();  // Giữ cho backward compatibility
```

**Import thêm:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```

---

## 🎯 TÓM TẮT CÁC BƯỚC

| Bước | Nội dung | Thời gian | Priority |
|------|----------|-----------|----------|
| 1 | Fix critical bugs | 15 phút | 🔴 High |
| 2 | Thống nhất data structure | 30 phút | 🔴 High |
| 3 | Copy files | 5 phút | 🔴 High |
| 4 | Update pubspec.yaml | 10 phút | 🔴 High |
| 5 | Khởi tạo NotificationProvider | 20 phút | 🔴 High |
| 6 | Fix routes | 15 phút | 🟡 Medium |
| 7 | Integrate vào plant detail | 30 phút | 🔴 High |
| 8 | Setup Android notifications | 15 phút | 🟡 Medium |
| 9 | Test integration | 30 phút | 🔴 High |
| 10 | Fix data structure queries | 30 phút | 🔴 High |
| 11 | Fix timestamp field | 20 phút | 🟡 Medium |

**Tổng thời gian:** ~3.5 giờ

---

## 🚨 NHỮNG LỖI THƯỜNG GẶP

### **1. App crash khi mở statistics**
**Nguyên nhân:** Không truyền plantId
**Giải pháp:** Check Bước 6

### **2. Biểu đồ không có data**
**Nguyên nhân:** Query sai collection
**Giải pháp:** Check Bước 10

### **3. Notification không hiển thị**
**Nguyên nhân:** Thiếu permission hoặc icon path sai
**Giải pháp:** Check Bước 1 & 8

### **4. Build Android failed**
**Nguyên nhân:** Firebase dependencies conflict
**Giải pháp:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## ✅ CHECKLIST HOÀN THÀNH

Sau khi làm xong TẤT CẢ các bước, check:

- [ ] App build thành công (Android & iOS)
- [ ] Không có lỗi import
- [ ] NotificationProvider initialize thành công
- [ ] Statistics screen mở được
- [ ] Biểu đồ hiển thị (hoặc "Không có dữ liệu")
- [ ] FCM token được lưu vào Firestore
- [ ] Sensor listening hoạt động
- [ ] Test với mock data thành công

---

## 📞 HỖ TRỢ

Nếu gặp lỗi, check:
1. Console logs (terminal chạy `flutter run`)
2. Firebase Console > Firestore (xem data có đúng không)
3. Android Studio Logcat (xem native logs)

**Good luck!** 🚀

